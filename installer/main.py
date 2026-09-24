#!/usr/bin/env python3
"""Main entrypoint for NixOS Everforest Live Installer."""

import argparse
import os
import sys
from pathlib import Path

# Ensure repository root is on sys.path for direct script execution
REPO_ROOT = str(Path(__file__).resolve().parent.parent)
if REPO_ROOT not in sys.path:
    sys.path.insert(0, REPO_ROOT)

import installer.config as config
from rich.panel import Panel
from rich.prompt import Prompt
from installer.theme import console
from installer.models import HostInfo, DiskInfo, InstallConfig
from installer.screens import (
    WelcomeScreen,
    HostSelectScreen,
    DiskSelectScreen,
    AgeKeyPromptScreen,
    PasswordPromptScreen,
    SummaryConfirmScreen,
    CompletionScreen,
)
from installer.progress import InstallPipeline
from installer.services.executor import CommandExecutor, InstallError
from installer.services import hardware_service, host_service


def get_mock_hosts() -> list[HostInfo]:
    return [
        HostInfo(
            name="thinkpad",
            description="Lenovo ThinkPad P1 Gen 2 (Intel + NVIDIA Quadro, Hybrid)",
            arch="x86_64-linux",
            boot_mode="UEFI",
            disko_layout="btrfs-uefi",
        ),
        HostInfo(
            name="dev",
            description="QEMU/KVM Virtual Machine (virgl, SPICE)",
            arch="x86_64-linux",
            boot_mode="BIOS",
            disko_layout="btrfs-bios",
        ),
    ]


def get_mock_disks() -> list[DiskInfo]:
    return [
        DiskInfo(
            path="/dev/nvme0n1",
            model="SAMSUNG MZVLB512HBJQ-000L7",
            size_gb=476.9,
            is_nvme=True,
            is_removable=False,
        ),
        DiskInfo(
            path="/dev/sda",
            model="Samsung SSD 860 EVO 500GB",
            size_gb=500.0,
            is_nvme=False,
            is_removable=False,
        ),
        DiskInfo(
            path="/dev/sdb",
            model="Kingston DataTraveler 3.0",
            size_gb=32.0,
            is_nvme=False,
            is_removable=True,
        ),
    ]


def main() -> None:
    parser = argparse.ArgumentParser(description="NixOS Everforest Live Installer")
    parser.add_argument(
        "--execute",
        action="store_true",
        help="Enable real command execution (default: dry-run — commands are captured, not run)",
    )
    parser.add_argument(
        "--repo",
        type=Path,
        default=config.DEFAULT_REPO,
        help=f"Path to the flake repository (default: {config.DEFAULT_REPO})",
    )
    parser.add_argument(
        "--log",
        type=Path,
        default=Path("/tmp/nixos-installer.log"),
        help="Full command/output log file (default: /tmp/nixos-installer.log)",
    )
    parser.add_argument(
        "--mock",
        action="store_true",
        help="Use hardcoded hosts/disks instead of live hardware discovery (pure UI test)",
    )
    args = parser.parse_args()

    executor = CommandExecutor(dry_run=not args.execute, log_file=args.log)
    cfg = InstallConfig()
    # Real execution mutates disks — refuse to run unprivileged. Dry-run stays
    # available as non-root for development and UI testing.
    if args.execute and os.geteuid() != 0:
        console.print(
            "[error]✗ Режим --execute требует root. "
            "Перезапустите через sudo (sudo nixos-installer).[/error]"
        )
        sys.exit(1)

    cfg.dry_run = not args.execute

    try:
        # Step 0: Welcome & Pre-flight
        WelcomeScreen.show()

        # Step 1: Host Profile Selection
        if args.mock:
            available_hosts = get_mock_hosts()
        else:
            available_hosts = host_service.discover_hosts(args.repo)
            if not available_hosts:
                console.print(f"[error]✗ Хосты не обнаружены в {args.repo}/hosts[/error]")
                sys.exit(1)
        config.target_host = HostSelectScreen.prompt(available_hosts)
        cfg.target_host = config.target_host

        # Step 2: Target Disk Selection
        if args.mock:
            detected_disks = get_mock_disks()
        else:
            detected_disks = hardware_service.list_disks(executor)
            if not detected_disks:
                console.print("[error]✗ Физические диски не обнаружены[/error]")
                sys.exit(1)
        config.target_disk = DiskSelectScreen.prompt(detected_disks)
        cfg.target_disk = config.target_disk
        # Preflight: refuse to destroy a disk that is still mounted anywhere
        # (e.g. the old system mounted at /mnt/disk for data rescue).
        if args.execute:
            busy_mounts = hardware_service.find_disk_mounts(cfg.target_disk.path)
            if busy_mounts:
                console.print(
                    f"[error]✗ Диск {cfg.target_disk.path} смонтирован:[/error]"
                )
                for m in busy_mounts:
                    console.print(f"  [fg]• {m}[/fg]")
                console.print(
                    "[warning]Размонтируйте его (sudo umount …) или выберите другой диск. "
                    "Ничего не изменено.[/warning]"
                )
                sys.exit(1)

        # Step 3: Age Master Key Prompt
        cfg.age_master_key = AgeKeyPromptScreen.prompt()

        # Step 4: User Password for the installed system
        cfg.user_password = PasswordPromptScreen.prompt()

        # Step 5: Summary & Confirmation
        if not SummaryConfirmScreen.prompt(cfg):
            console.print("\n[warning]● Установка отменена пользователем. Никаких изменений на диск не внесено.[/warning]\n")
            sys.exit(0)

        # Step 6: Installation Pipeline (real services; dry-run unless --execute)
        pipeline = InstallPipeline(executor, args.repo, cfg)
        try:
            pipeline.run()
        except InstallError as e:
            console.print()
            console.print(
                Panel(
                    f"[bold red]✗ КОМАНДА УСТАНОВКИ ЗАВЕРШИЛАСЬ С ОШИБКОЙ[/bold red]\n\n"
                    f"[fg]{e}[/fg]\n\n"
                    + (
                        f"[fg]Последние строки вывода:[/fg]\n"
                        + "\n".join(f"[muted]│[/muted] {line}" for line in e.tail)
                        + "\n\n"
                        if e.tail
                        else ""
                    )
                    + f"[warning]Полный журнал: {args.log}[/warning]",
                    border_style="red",
                    padding=(0, 1),
                )
            )
            console.print()
            choice = Prompt.ask(
                "[prompt]Дальнейшие действия[/prompt]",
                choices=["shell", "abort"],
                default="shell",
            )
            if choice == "shell":
                console.print("[info]Имитация: переход в shell для диагностики (journalctl, lsblk)...[/info]")
            sys.exit(1)

        # Step 7: Completion
        if executor.dry_run:
            console.print(
                f"\n[muted]Dry-run: всего зафиксировано команд — {len(executor.executed)}. "
                "Для реальной установки запустите с флагом --execute.[/muted]"
            )
        CompletionScreen.show()

    except KeyboardInterrupt:
        console.print("\n\n[error]✗ Процесс прерван комбинацией Ctrl+C. Выход.[/error]\n")
        sys.exit(130)


if __name__ == "__main__":
    main()

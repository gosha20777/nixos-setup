#!/usr/bin/env python3
"""Main entrypoint for NixOS Everforest Live Installer (Mock UI)."""
import sys
from pathlib import Path

# Ensure repository root is on sys.path for direct script execution
REPO_ROOT = str(Path(__file__).resolve().parent.parent)
if REPO_ROOT not in sys.path:
    sys.path.insert(0, REPO_ROOT)

from installer.theme import console
from installer.models import HostInfo, DiskInfo, InstallConfig
from installer.screens import (
    WelcomeScreen,
    HostSelectScreen,
    DiskSelectScreen,
    AgeKeyPromptScreen,
    SummaryConfirmScreen,
    CompletionScreen,
)
from installer.progress import MockInstallPipeline


def main() -> None:
    # Simulated discovery data for testing UI interaction
    available_hosts = [
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

    detected_disks = [
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

    config = InstallConfig()

    try:
        # Step 0: Welcome & Pre-flight
        WelcomeScreen.show()

        # Step 1: Host Profile Selection
        config.target_host = HostSelectScreen.prompt(available_hosts)

        # Step 2: Target Disk Selection
        config.target_disk = DiskSelectScreen.prompt(detected_disks)

        # Step 3: Age Master Key Prompt
        config.age_master_key = AgeKeyPromptScreen.prompt()

        # Step 4: Summary & Confirmation
        if not SummaryConfirmScreen.prompt(config):
            console.print("\n[warning]● Установка отменена пользователем. Никаких изменений на диск не внесено.[/warning]\n")
            sys.exit(0)

        # Step 5: Simulated Installation Pipeline
        MockInstallPipeline.run(config)

        # Step 6: Completion
        CompletionScreen.show()

    except KeyboardInterrupt:
        console.print("\n\n[error]✗ Процесс прерван комбинацией Ctrl+C. Выход.[/error]\n")
        sys.exit(130)


if __name__ == "__main__":
    main()

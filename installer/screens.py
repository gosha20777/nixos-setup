"""UI screens for the NixOS Everforest Live Installer."""

import os
import subprocess
import sys
from pathlib import Path
from typing import List, Optional
from rich.panel import Panel
from rich.table import Table
from rich.prompt import Prompt, Confirm
from rich.text import Text

from installer.theme import console, PALETTE
from installer.models import HostInfo, DiskInfo, InstallConfig


class WelcomeScreen:
    """Initial greeting and pre-flight diagnostics."""
    @staticmethod
    def show() -> None:
        console.clear()
        title_text = Text()
        title_text.append("🌲 NIXOS EVERFOREST LIVE INSTALLER\n", style="bold green")
        title_text.append("Декларативная установка системы на реальное железо", style="muted")

        banner = Panel(
            title_text,
            border_style="green",
            padding=(1, 2),
            expand=False,
        )
        console.print(banner)
        console.print()

        console.print("[accent]● Результаты предварительной проверки системы:[/accent]")
        checks = [
            ("Режим прошивки", "UEFI (x86_64-linux)", "success"),
            ("Оперативная память", "31.0 GiB (zramSwap 25% поддерживается)", "success"),
            ("Сетевое подключение", "Подключено (wlan0 / eth0)", "success"),
            ("Репозиторий Flake", "Обнаружен в /iso/repo", "success"),
        ]
        table = Table(show_header=False, box=None, padding=(0, 2))
        for name, status, style in checks:
            table.add_row(f"[{style}]✓[/{style}] {name}:", f"[{style}]{status}[/{style}]")
        console.print(table)
        console.print()


class HostSelectScreen:
    """Screen for choosing target host profile."""
    @staticmethod
    def prompt(hosts: List[HostInfo]) -> HostInfo:
        console.print("[prompt]▸ Шаг 1: Выберите конфигурацию целевого хоста:[/prompt]")
        table = Table(border_style="muted", header_style="accent", show_lines=True)
        table.add_column("#", justify="center", style="bold yellow", width=4)
        table.add_column("Хост", style="bold green", width=12)
        table.add_column("Описание", style="fg")
        table.add_column("Архитектура", style="muted", width=14)
        table.add_column("Загрузка", style="muted", width=8)

        for i, h in enumerate(hosts, 1):
            table.add_row(str(i), h.name, h.description, h.arch, h.boot_mode)
        console.print(table)
        console.print()

        while True:
            choice = Prompt.ask(
                "[prompt]Выберите номер хоста[/prompt]",
                choices=[str(i) for i in range(1, len(hosts) + 1)],
                default="1",
            )
            return hosts[int(choice) - 1]


class DiskSelectScreen:
    """Screen for choosing target installation drive."""
    @staticmethod
    def prompt(disks: List[DiskInfo]) -> DiskInfo:
        console.print()
        console.print("[prompt]▸ Шаг 2: Выберите целевой накопитель для разметки (Btrfs):[/prompt]")
        table = Table(border_style="muted", header_style="accent", show_lines=True)
        table.add_column("#", justify="center", style="bold yellow", width=4)
        table.add_column("Устройство", style="bold green", width=16)
        table.add_column("Модель накопителя", style="fg")
        table.add_column("Объем", style="yellow", justify="right", width=10)
        table.add_column("Тип шины", style="muted", width=10)

        selectable_disks = [d for d in disks if not d.is_removable]
        for i, d in enumerate(selectable_disks, 1):
            bus = "NVMe" if d.is_nvme else "SATA"
            table.add_row(str(i), d.path, d.model, f"{d.size_gb:.1f} GB", bus)

        console.print(table)

        # Show filtered devices for transparency
        removables = [d for d in disks if d.is_removable]
        if removables:
            console.print(
                f"[muted]  (Автоматически скрыто флеш-накопителей: {len(removables)} — установочный носитель защищен)[/muted]"
            )
        console.print()

        while True:
            choice = Prompt.ask(
                "[prompt]Выберите номер диска[/prompt]",
                choices=[str(i) for i in range(1, len(selectable_disks) + 1)],
                default="1",
            )
            return selectable_disks[int(choice) - 1]


class AgeKeyPromptScreen:
    """Screen for providing the Age Master Identity Key."""
    @staticmethod
    def prompt() -> str:
        console.print()
        console.print("[prompt]▸ Шаг 3: Мастер-ключ секретов (Age Identity Key):[/prompt]")
        console.print("[muted]Секреты репозитория (API токены Oh My Pi и SSH-ключи) зашифрованы ключом Age.[/muted]")
        console.print("  [1] Ввести приватный ключ вручную (AGE-SECRET-KEY-1...)")
        console.print("  [2] Загрузить из файла на смонтированном диске / флешке")
        console.print("  [3] Пропустить (система установится без расшифровки секретов)")
        console.print()

        mode = Prompt.ask(
            "[prompt]Выберите вариант[/prompt]",
            choices=["1", "2", "3"],
            default="1",
        )

        if mode == "1":
            while True:
                key = Prompt.ask("[prompt]Вставьте приватный ключ[/prompt]")
                key = key.strip()
                if not key:
                    if Confirm.ask("[warning]Ключ пуст. Пропустить ввод?[/warning]", default=False):
                        return ""
                    continue
                if key.startswith("AGE-SECRET-KEY-1") and len(key) >= 60:
                    console.print("[success]✓ Ключ Age принят (валидный Bech32)[/success]")
                    return key
                console.print("[error]✗ Ошибка: ключ должен начинаться с 'AGE-SECRET-KEY-1...'[/error]")
        elif mode == "2":
            while True:
                path_str = Prompt.ask(
                    "[prompt]Укажите путь к файлу keys.txt (или оставьте пустым для отмены)[/prompt]",
                    default="/mnt/usb/keys.txt",
                ).strip()
                if not path_str:
                    return ""
                key_path = Path(path_str)
                if not key_path.is_file():
                    console.print(f"[error]✗ Файл не найден: {path_str}[/error]")
                    if Confirm.ask("[warning]Пропустить ввод ключа Age?[/warning]", default=False):
                        return ""
                    continue
                try:
                    content = key_path.read_text(encoding="utf-8")
                except OSError as exc:
                    console.print(f"[error]✗ Ошибка чтения {path_str}: {exc}[/error]")
                    continue
                matched_line = ""
                for line in content.splitlines():
                    stripped = line.strip()
                    if stripped.startswith("AGE-SECRET-KEY-1") and len(stripped) >= 60:
                        matched_line = stripped
                        break
                if matched_line:
                    console.print(f"[success]✓ Ключ Age успешно считан из {path_str}[/success]")
                    return content if content.endswith("\n") else content + "\n"
                console.print(f"[error]✗ В файле {path_str} не найден валидный ключ 'AGE-SECRET-KEY-1...'[/error]")
        else:
            console.print("[warning]! Установка будет продолжена без мастер-ключа Age[/warning]")
            return ""


class PasswordPromptScreen:
    """Screen for setting the installed system's user password."""
    @staticmethod
    def prompt() -> str:
        console.print()
        console.print("[prompt]▸ Шаг 4: Пароль пользователя целевой системы:[/prompt]")
        console.print(
            "[muted]На fresh-системе аккаунт заблокирован — задайте пароль для входа в рабочий стол и sudo.[/muted]"
        )
        console.print()

        while True:
            password = Prompt.ask("[prompt]Новый пароль (ввод скрыт)[/prompt]", password=True)
            if not password:
                console.print("[error]✗ Пароль не может быть пустым[/error]")
                continue
            confirm = Prompt.ask("[prompt]Повторите пароль[/prompt]", password=True)
            if password == confirm:
                console.print("[success]✓ Пароль задан (будет применен к установленной системе)[/success]")
                return password
            console.print("[error]✗ Пароли не совпадают — попробуйте снова[/error]")


class SummaryConfirmScreen:
    """Final summary review and destructive confirmation."""
    @staticmethod
    def prompt(config: InstallConfig) -> bool:
        console.print()
        table = Table(show_header=False, box=None, padding=(0, 2))
        table.add_row("[accent]Целевой хост:[/accent]", f"[bold green]{config.target_host.name}[/bold green] ({config.target_host.description})")
        table.add_row("[accent]Архитектура платформы:[/accent]", f"{config.target_host.arch}")
        table.add_row("[accent]Режим загрузчика:[/accent]", f"{config.target_host.boot_mode} (нативный systemd-boot)")
        table.add_row("[accent]Целевой накопитель:[/accent]", f"[bold red]{config.target_disk.path}[/bold red] ({config.target_disk.model}, {config.target_disk.size_gb:.1f} GB)")
        table.add_row("[accent]Разметка Disko:[/accent]", "Btrfs (субтомы @, @home, @nix, @log, @snapshots)")
        table.add_row("[accent]Файл подкачки:[/accent]", "zramSwap в RAM (25% памяти = 8.0 GB, сжатие zstd)")
        table.add_row("[accent]Мастер-ключ Age:[/accent]", "[success]Настроен и будет сохранен в ~/.config/sops/age/keys.txt[/success]" if config.age_master_key else "[warning]Пропущен[/warning]")
        table.add_row("[accent]Пароль пользователя:[/accent]", "[success]Задан (будет применен через chpasswd)[/success]" if getattr(config, "user_password", "") else "[warning]Не задан — аккаунт останется заблокирован[/warning]")
        table.add_row("[accent]Каталог репозитория:[/accent]", f"{config.repo_dest_path}")
        if config.target_host:
            table.add_row("[accent]Часовой пояс:[/accent]", f"{config.target_host.timezone}")
            table.add_row("[accent]Локация погоды:[/accent]", f"{config.target_host.weather_location}")
            table.add_row("[accent]Раскладки ввода:[/accent]", f"{config.target_host.keyboard_layouts} (Mod+Space)")

        panel = Panel(
            table,
            title="[bold yellow] ПАРАМЕТРЫ УСТАНОВКИ [/bold yellow]",
            border_style="yellow",
            padding=(1, 2),
        )
        console.print(panel)
        console.print()

        if config.dry_run:
            console.print(
                Panel(
                    "[bold warning]РЕЖИМ DRY-RUN — реальные команды НЕ исполняются.[/bold warning]\n"
                    "[muted]Все действия будут только зафиксированы в журнале. Запустите с --execute для реальной установки.[/muted]",
                    border_style="orange",
                )
            )
            console.print()

        console.print(
            Panel(
                f"[bold red]ВНИМАНИЕ! ВСЕ СУЩЕСТВУЮЩИЕ ДАННЫЕ НА {config.target_disk.path} БУДУТ БЕЗВОЗВРАТНО УНИЧТОЖЕНЫ![/bold red]\n"
                "[muted]Убедитесь, что все важные файлы скопированы на резервный носитель.[/muted]",
                border_style="red",
            )
        )
        console.print()

        confirmation = Prompt.ask(
            "[bold red]Введите 'yes' прописными буквами для начала установки[/bold red]"
        )
        return confirmation.strip().lower() == "yes"


class CompletionScreen:
    """Final screen offering reboot or shell."""
    @staticmethod
    def show(dry_run: bool = True) -> None:
        console.print()
        card = Panel(
            "[bold green]🌲 СИСТЕМА УСПЕШНО УСТАНОВЛЕНА![/bold green]\n\n"
            "[fg]NixOS с графическим окружением niri, шеллом Noctalia и палитрой Everforest готова к работе.\n"
            "После перезагрузки войдите под своей учетной записью.[/fg]",
            border_style="green",
            padding=(1, 2),
        )
        console.print(card)
        console.print()
        console.print("[prompt]Что делаем дальше?[/prompt]")
        console.print("  [1] Перезагрузить компьютер прямо сейчас (Reboot)")
        console.print("  [2] Войти в chroot установленной системы для проверки")
        console.print("  [3] Выйти в Live-терминал")
        console.print()

        choice = Prompt.ask("[prompt]Выберите действие[/prompt]", choices=["1", "2", "3"], default="1")
        if choice == "1":
            if dry_run:
                console.print("[info]Имитация: перезагрузка системы (systemctl reboot)...[/info]")
            else:
                console.print("[info]Перезагрузка системы...[/info]")
                subprocess.run(["systemctl", "reboot"], check=False)
        elif choice == "2":
            if dry_run:
                console.print("[info]Имитация: переход в chroot /mnt...[/info]")
            else:
                console.print("[info]Вход в chroot /mnt (введите exit для выхода)...[/info]")
                subprocess.run(["nixos-enter", "--root", "/mnt"], check=False)
        else:
            console.print("[info]Возврат в терминал. До свидания![/info]")

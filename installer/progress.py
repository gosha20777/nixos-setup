"""Installation pipeline progress simulation for Mock UI."""

import time
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TimeElapsedColumn
from installer.theme import console
from installer.models import InstallConfig


class MockInstallPipeline:
    """Simulates the backend execution pipeline with visual feedback."""

    STEPS = [
        ("Разметка диска и создание Btrfs субтомов (Disko)...", 2.0),
        ("Сохранение мастер-ключа Age (~/.config/sops/age/keys.txt)...", 1.0),
        ("Установка NixOS (nixos-install)... Копирование пакетов из кэша", 3.0),
        ("Развертывание репозитория в ~/Projects/nixos-setup...", 1.5),
        ("Настройка прав доступа пользователя и генерация загрузчика...", 1.0),
    ]

    @classmethod
    def run(cls, config: InstallConfig) -> bool:
        console.print()
        console.print("[accent]🚀 Запуск процесса установки NixOS...[/accent]")
        console.print()

        with Progress(
            SpinnerColumn(spinner_name="dots", style="bold green"),
            TextColumn("[progress.description]{task.description}"),
            BarColumn(bar_width=30, style="bg1", complete_style="green"),
            TimeElapsedColumn(),
            console=console,
        ) as progress:
            total_task = progress.add_task("[bold yellow]Общий прогресс установки[/bold yellow]", total=len(cls.STEPS))

            for step_name, duration in cls.STEPS:
                sub_task = progress.add_task(f"[fg]{step_name}[/fg]", total=100)
                # Simulate smooth step execution
                intervals = 20
                for _ in range(intervals):
                    time.sleep(duration / intervals)
                    progress.update(sub_task, advance=100 / intervals)
                progress.remove_task(sub_task)
                progress.update(total_task, advance=1)
                console.print(f"  [success]✓[/success] {step_name}")

        console.print()
        return True

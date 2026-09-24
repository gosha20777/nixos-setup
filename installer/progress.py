"""Installation pipeline with visual progress and real service calls.

Long-running steps (disko, nixos-install) stream their live output into a
Rich panel; every line is also appended to the executor's log file.
"""

from collections import deque

from rich.live import Live
from rich.panel import Panel
from rich.table import Table
from rich.text import Text
from rich.rule import Rule

from installer.theme import console
from installer.models import InstallConfig
from installer.services.executor import CommandExecutor
from installer.services import disko_service, secrets_service, nixos_service, repo_service
import installer.config as config

# Lines shown in the live stream panel
VIEW_LINES = 12


class InstallPipeline:
    """Executes the installation pipeline through services, with visual progress."""

    def __init__(self, executor: CommandExecutor, repo, config: InstallConfig) -> None:
        self.executor = executor
        self.repo = repo
        self.config = config

    def run(self) -> bool:
        console.print()
        console.print("[accent]🚀 Запуск процесса установки NixOS...[/accent]")
        if self.executor.dry_run:
            console.print(
                "[warning]РЕЖИМ DRY-RUN — команды будут только зафиксированы, диск не изменится[/warning]"
            )
        console.print()

        cfg = self.config
        host = cfg.target_host.name

        # Fast steps: instant capture (or instant real execution)
        console.print("[fg]▸ Сохранение мастер-ключа Age (~/.config/sops/age/keys.txt)...[/fg]")
        secrets_service.provision(
            self.executor, config.MOUNT_POINT, cfg.username, cfg.age_master_key
        )
        console.print("  [success]✓ Сохранение мастер-ключа Age[/success]")

        console.print("[fg]▸ Установка пароля пользователя целевой системы...[/fg]")
        if cfg.user_password:
            nixos_service.set_user_password(
                self.executor, config.MOUNT_POINT, cfg.username, cfg.user_password
            )
            console.print("  [success]✓ Пароль пользователя установлен[/success]")
        else:
            console.print("  [warning]! Пароль пропущен — аккаунт останется заблокирован[/warning]")

        # Long step 1: Disko with live streaming output
        self._stream_step(
            "Разметка диска и создание Btrfs субтомов (Disko)",
            disko_service.format_and_mount_cmd(self.repo, host),
        )

        # Long step 2: NixOS install with live streaming output
        self._stream_step(
            "Установка NixOS (nixos-install)... Копирование пакетов из кэша",
            nixos_service.install_cmd(self.repo, host),
        )

        # Fast steps: repo deployment
        console.print("[fg]▸ Развертывание репозитория в ~/Projects/nixos-setup...[/fg]")
        repo_service.deploy(
            self.executor, self.repo, config.MOUNT_POINT, cfg.username
        )
        console.print("  [success]✓ Развертывание репозитория[/success]")

        console.print()

        if self.executor.dry_run:
            console.print("[warning]DRY-RUN ЗАВЕРШЕН: реальные команды НЕ исполнялись[/warning]")
            table = Table(
                title="Захваченные команды (аудит dry-run)",
                header_style="accent",
                border_style="muted",
                show_lines=True,
            )
            table.add_column("#", style="bold yellow", width=4)
            table.add_column("Команда")
            for i, cmd in enumerate(self.executor.executed, 1):
                table.add_row(str(i), " ".join(cmd))
            console.print(table)
        return True

    def _stream_step(self, title: str, cmd: list[str]) -> None:
        """Run a long command with a live-updating output panel."""
        if self.executor.dry_run:
            console.print(f"[fg]▸ {title}[/fg]")
            self.executor.run_streaming(cmd)
            console.print("  [success]✓[/success] " + title.split("...")[0])
            return

        console.print(f"[fg]▸ {title}[/fg]")
        tail = deque(maxlen=VIEW_LINES)

        with Live(console=console, refresh_per_second=8) as live:

            def on_line(line: str) -> None:
                tail.append(line)
                live.update(self._render_stream(tail))

            self.executor.run_streaming(cmd, on_line=on_line)

        console.print("  [success]✓[/success] " + title.split("...")[0])

    @staticmethod
    def _render_stream(tail: deque) -> Panel:
        body = Text("\n".join(tail) if tail else "ожидание вывода команды...", style="fg")
        return Panel(
            body,
            title="[accent]▼ live output[/accent]",
            border_style="muted",
            padding=(0, 1),
        )
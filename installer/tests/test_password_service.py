"""Tests for set_user_password: chroot chpasswd command construction."""

from pathlib import Path

from installer.services.nixos_service import set_user_password
from installer.services.executor import CommandExecutor


class TestDryRun:
    def test_builds_chroot_chpasswd_command(self):
        executor = CommandExecutor(dry_run=True)

        set_user_password(executor, Path("/mnt"), "gosha20777", "hunter2secure")

        assert executor.executed == [
            ["chroot", "/mnt", "chpasswd"]
        ]

    def test_password_not_in_audit_log(self, tmp_path: Path):
        log = tmp_path / "install.log"
        executor = CommandExecutor(dry_run=True, log_file=log)

        set_user_password(executor, Path("/mnt"), "gosha20777", "hunter2secure")

        content = log.read_text()
        assert "chroot /mnt chpasswd" in content
        assert "hunter2secure" not in content  # stdin never logged


class TestRealExecution:
    def test_stdin_data_reaches_command(self):
        executor = CommandExecutor(dry_run=False)

        result = executor.run(
            ["python3", "-c", "import sys; assert sys.stdin.read() == 'gosha20777:pass1234\\n'; print('ok')"],
            stdin_data="gosha20777:pass1234\n",
        )

        assert result.exit_code == 0
        assert "ok" in result.stdout

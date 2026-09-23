"""Tests for SecretsService: Age key provisioning."""

from pathlib import Path
import os

from installer.services.secrets_service import provision
from installer.services.executor import CommandExecutor


KEY = "AGE-SECRET-KEY-1TESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTESTTEST"


class TestRealProvision:
    def test_key_written_with_0600(self, tmp_path: Path):
        executor = CommandExecutor(dry_run=False)
        mount = tmp_path / "mnt"

        provision(executor, mount, "gosha20777", KEY)

        key_file = mount / "home" / "gosha20777" / ".config" / "sops" / "age" / "keys.txt"
        assert key_file.exists()
        assert key_file.read_text() == KEY
        assert os.stat(key_file).st_mode & 0o777 == 0o600

    def test_command_in_audit_log(self, tmp_path: Path):
        executor = CommandExecutor(dry_run=True)
        mount = tmp_path / "mnt"

        provision(executor, mount, "gosha20777", KEY)

        assert len(executor.executed) == 1
        cmd = executor.executed[0]
        assert cmd[:3] == ["install", "-D", "-m"]
        assert "600" in cmd
        assert cmd[-1].endswith("keys.txt")


class TestSkipWhenEmpty:
    def test_empty_key_skips_entirely(self, tmp_path: Path):
        executor = CommandExecutor(dry_run=True)
        mount = tmp_path / "mnt"

        provision(executor, mount, "gosha20777", "")

        assert executor.executed == []
        assert not (mount / "home").exists()

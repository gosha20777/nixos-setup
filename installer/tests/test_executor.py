"""Tests for CommandExecutor: dry-run capture vs real execution."""

import subprocess
from pathlib import Path

import pytest

from installer.services.executor import CommandExecutor, InstallError


class TestDryRun:
    def test_run_captures_command_and_does_not_execute(self, tmp_path: Path):
        executor = CommandExecutor(dry_run=True)
        marker = tmp_path / "should_not_exist"

        result = executor.run(["touch", str(marker)])

        assert result.exit_code == 0
        assert marker.exists() is False  # dry-run must NOT execute
        assert executor.executed == [["touch", str(marker)]]

    def test_run_appends_to_audit_log_in_order(self):
        executor = CommandExecutor(dry_run=True)
        executor.run(["cmd-a", "1"])
        executor.run(["cmd-b", "2"])

        assert executor.executed == [["cmd-a", "1"], ["cmd-b", "2"]]


class TestReadonly:
    def test_run_readonly_executes_even_in_dry_run(self):
        executor = CommandExecutor(dry_run=True)

        result = executor.run_readonly(["echo", "hi"])

        assert result.exit_code == 0
        assert result.stdout == "hi\n"
        assert executor.executed == []  # read-only never pollutes the audit log


class TestRealExecution:
    def test_run_false_check_false_returns_nonzero(self):
        executor = CommandExecutor(dry_run=False)

        result = executor.run(["false"], check=False)

        assert result.exit_code == 1

    def test_run_false_check_true_raises_install_error(self):
        executor = CommandExecutor(dry_run=False)

        with pytest.raises(InstallError):
            executor.run(["false"], check=True)

    def test_run_real_touch_creates_file(self, tmp_path: Path):
        executor = CommandExecutor(dry_run=False)
        marker = tmp_path / "created"

        executor.run(["touch", str(marker)])

        assert marker.exists() is True

    def test_dry_run_is_default(self):
        assert CommandExecutor().dry_run is True


class TestStreaming:
    def test_stream_dry_run_captures_without_executing(self, tmp_path: Path):
        executor = CommandExecutor(dry_run=True)
        marker = tmp_path / "should_not_exist"

        result = executor.run_streaming(["touch", str(marker)])

        assert result.exit_code == 0
        assert marker.exists() is False
        assert executor.executed == [["touch", str(marker)]]

    def test_stream_real_passes_lines_to_callback(self):
        executor = CommandExecutor(dry_run=False)
        received: list[str] = []

        executor.run_streaming(["echo", "hello"], on_line=received.append)

        assert received == ["hello"]

    def test_stream_real_merges_stderr_into_output(self):
        executor = CommandExecutor(dry_run=False)
        received: list[str] = []

        executor.run_streaming(
            [
                "python3",
                "-c",
                "import sys; sys.stdout.write('out\\n'); sys.stderr.write('err\\n')",
            ],
            on_line=received.append,
            check=False,
        )

        assert "out" in received
        assert "err" in received

    def test_stream_error_carries_tail(self):
        executor = CommandExecutor(dry_run=False)
        received: list[str] = []

        with pytest.raises(InstallError) as exc_info:
            executor.run_streaming(
                ["python3", "-c", "print('before'); raise SystemExit(2)"],
                on_line=received.append,
            )

        assert exc_info.value.tail == ["before"]


class TestLogFile:
    def test_run_logs_invocation_and_output(self, tmp_path: Path):
        log = tmp_path / "install.log"
        executor = CommandExecutor(dry_run=False, log_file=log)

        executor.run(["echo", "payload"])

        content = log.read_text()
        assert "$ echo payload" in content
        assert "payload" in content
        assert "===" in content  # header

    def test_dry_run_also_logs_invocations(self, tmp_path: Path):
        log = tmp_path / "install.log"
        executor = CommandExecutor(dry_run=True, log_file=log)

        executor.run(["disko", "--mode", "destroy,format,mount"])

        content = log.read_text()
        assert "$ disko --mode destroy,format,mount" in content

    def test_stream_logs_lines(self, tmp_path: Path):
        log = tmp_path / "install.log"
        executor = CommandExecutor(dry_run=False, log_file=log)

        executor.run_streaming(["echo", "streamed"])

        content = log.read_text()
        assert "$ echo streamed" in content
        assert "streamed" in content

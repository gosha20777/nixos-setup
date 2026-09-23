"""Tests for DiskoService: command construction."""

from pathlib import Path

from installer.services.disko_service import format_and_mount
from installer.services.executor import CommandExecutor


def test_format_and_mount_builds_exact_command():
    executor = CommandExecutor(dry_run=True)
    repo = Path("/iso/repo")

    format_and_mount(executor, repo, "thinkpad")

    assert executor.executed == [
        ["disko", "--mode", "destroy,format,mount", "--flake", "/iso/repo#thinkpad"]
    ]

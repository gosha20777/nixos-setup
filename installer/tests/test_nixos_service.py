"""Tests for NixOSService: install command construction."""

from pathlib import Path

from installer.services.nixos_service import install
from installer.services.executor import CommandExecutor


def test_install_builds_exact_command():
    executor = CommandExecutor(dry_run=True)
    repo = Path("/iso/repo")

    install(executor, repo, "thinkpad")

    assert executor.executed == [
        ["nixos-install", "--flake", "/iso/repo#thinkpad", "--no-root-password"]
    ]

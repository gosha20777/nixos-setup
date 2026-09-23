"""NixOS installation service."""

from pathlib import Path

from installer.services.executor import CommandExecutor, CommandResult


def install_cmd(repo: Path, host: str) -> list[str]:
    """Build the nixos-install command (used by both run and run_streaming)."""
    return ["nixos-install", "--flake", f"{repo}#{host}", "--no-root-password"]


def install(executor: CommandExecutor, repo: Path, host: str) -> CommandResult:
    """Install NixOS into /mnt from the flake without a root password."""
    return executor.run(install_cmd(repo, host))

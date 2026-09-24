"""Disko partitioning service."""

from pathlib import Path

from installer.services.executor import CommandExecutor, CommandResult


def format_and_mount_cmd(repo: Path, host: str) -> list[str]:
    """Build the disko command (used by both run and run_streaming)."""
    return [
        "disko",
        "--mode",
        "destroy,format,mount",
        # Skip disko's interactive wipe confirmation: the installer already
        # confirms the target disk (SummaryConfirmScreen + mounted-disk
        # preflight) and an inherited-stdin prompt would hang the TUI forever.
        "--yes-wipe-all-disks",
        "--flake",
        f"{repo}#{host}",
    ]


def format_and_mount(executor: CommandExecutor, repo: Path, host: str) -> CommandResult:
    """Destroy, format, and mount the target disk per the host's Disko layout."""
    return executor.run(format_and_mount_cmd(repo, host))

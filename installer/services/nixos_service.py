"""NixOS installation service."""

from pathlib import Path

from installer.services.executor import CommandExecutor, CommandResult


def install_cmd(repo: Path, host: str) -> list[str]:
    """Build the nixos-install command (used by both run and run_streaming)."""
    return ["nixos-install", "--flake", f"{repo}#{host}", "--no-root-password"]


def install(executor: CommandExecutor, repo: Path, host: str) -> CommandResult:
    """Install NixOS into /mnt from the flake without a root password."""
    return executor.run(install_cmd(repo, host))


def set_user_password(
    executor: CommandExecutor, mount: Path, username: str, password: str
) -> CommandResult:
    """Set the primary user's password inside the freshly installed system.

    The password is piped via stdin (user:pass format) and is never written
    to the log file — only the chroot command itself is logged.
    """
    # Bare `chpasswd` resolves via the LIVE system's PATH, which does not
    # exist inside the chroot → exit 127. Use the absolute profile path:
    # inside the chroot it resolves through the system-1-link symlink
    # chain into the target's own store (verified against hosts/thinkpad).
    return executor.run(
        [
            "chroot",
            str(mount),
            "/nix/var/nix/profiles/system/sw/bin/chpasswd",
        ],
        stdin_data=f"{username}:{password}\n",
    )

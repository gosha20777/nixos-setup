"""Repository deployment service (copy flake into the installed system)."""

import installer.config as config
from pathlib import Path

from installer.services.executor import CommandExecutor


def deploy(executor: CommandExecutor, repo_src: Path, mount: Path, username: str) -> None:
    """Copy the flake repo into the target user's home and fix ownership/origin."""
    home = str(mount / "home" / username)
    dest = str(mount / "home" / username / config.REPO_DEST)
    # Create the Projects/ parent first (cp cannot create nested parents)
    executor.run(["install", "-d", str(mount / "home" / username / "Projects")])
    # Dereference symlinks (-L) because repo_src in the Live CD is a symlink into /nix/store
    executor.run(["cp", "-rL", str(repo_src), dest])
    # Ensure write permissions: Nix store files copied from Live CD are read-only (0444/0555)
    executor.run(["chmod", "-R", "u+w", dest])
    # git runs BEFORE chown: the fresh copy is root-owned, so git-as-root sees
    # no dubious-ownership error; the final chown hands everything to the user
    # (also fixes the age key's root-created parent dirs from secrets_service).
    executor.run(["git", "-C", dest, "remote", "set-url", "origin", config.GITHUB_ORIGIN])
    executor.run(["chown", "-R", "1000:100", home])
    storage = mount / "mnt" / "storage"
    if storage.exists():
        executor.run(["chown", "-R", "1000:100", str(storage)], check=False)

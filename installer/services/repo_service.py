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
    executor.run(["cp", "-r", str(repo_src), dest])
    executor.run(["chown", "-R", "1000:100", home])
    executor.run(["git", "-C", dest, "remote", "set-url", "origin", config.GITHUB_ORIGIN])

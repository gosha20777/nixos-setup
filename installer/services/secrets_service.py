"""Secrets provisioning service (Age master key)."""

import tempfile
from pathlib import Path

from installer.services.executor import CommandExecutor


def provision(executor: CommandExecutor, mount: Path, username: str, age_key: str) -> None:
    """Write the Age master key into the target system's user config dir.

    The key content is staged through a temp file so the final
    ``install -D -m 600`` lands in the dry-run audit log entirely.
    Empty age_key → step skipped entirely (no commands logged).
    """
    if not age_key:
        return
    dest = str(mount / "home" / username / ".config" / "sops" / "age" / "keys.txt")
    with tempfile.NamedTemporaryFile("w", suffix=".keys", delete=False) as tmp:
        tmp.write(age_key)
        tmp_path = tmp.name
    executor.run(["install", "-D", "-m", "600", tmp_path, dest])

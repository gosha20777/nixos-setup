"""Central command executor — the single safety gate for all system mutations.

Every mutating command (disko, nixos-install, cp, chown, ...) goes through
``CommandExecutor.run``. By default the executor is in dry-run mode: commands
are captured in ``self.executed`` but NOT executed. Real execution requires an
explicit opt-in (``CommandExecutor(dry_run=False)``), which is wired only from
the ``--execute`` CLI flag.

Read-only inspection commands (lsblk, /proc reads) use ``run_readonly`` and
always execute for real — they never mutate state.

Long-running commands (disko, nixos-install) use ``run_streaming``: their
output is streamed line by line to the log file and an optional ``on_line``
callback so the TUI can display live progress, and errors carry the last
``TAIL_LINES`` output lines for display.
"""

import os
import subprocess
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Callable, Optional


class InstallError(RuntimeError):
    """Raised when a real command fails and check=True.

    Carries ``tail`` — the last lines of merged output — for display in the UI.
    """

    def __init__(self, message: str, tail: Optional[list[str]] = None) -> None:
        super().__init__(message)
        self.tail = tail or []


@dataclass
class CommandResult:
    exit_code: int
    stdout: str
    stderr: str


# Number of trailing output lines kept for error display
TAIL_LINES = 30


class CommandExecutor:
    def __init__(self, dry_run: bool = True, log_file: Optional[Path] = None) -> None:
        self.dry_run = dry_run
        # Commands captured in dry-run mode (audit log)
        self.executed: list[list[str]] = []
        self.log_file = log_file
        if log_file is not None:
            log_file.parent.mkdir(parents=True, exist_ok=True)
            try:
                handle = open(log_file, "a")
            except PermissionError:
                # fs.protected_regular: O_CREAT on an existing file owned by
                # another uid in a sticky world-writable dir (/tmp) is denied
                # even to root — a stale log from a non-root run blocks a
                # root run and vice versa. Rotate it and start fresh.
                os.replace(log_file, log_file.with_suffix(log_file.suffix + ".old"))
                handle = open(log_file, "a")
            with handle as f:
                f.write(
                    f"\n=== NixOS installer log started "
                    f"{datetime.now():%Y-%m-%d %H:%M:%S} ===\n"
                )

    def _log(self, line: str) -> None:
        if self.log_file is None:
            return
        with open(self.log_file, "a") as f:
            f.write(f"[{datetime.now():%H:%M:%S}] {line}\n")

    def run(
        self,
        cmd: list[str],
        check: bool = True,
        stdin_data: Optional[str] = None,
    ) -> CommandResult:
        """Execute (or capture in dry-run) a potentially mutating command.

        ``stdin_data`` is piped to the command's stdin in real mode; it is
        deliberately NOT written to the log (used for passwords).
        """
        self.executed.append(list(cmd))
        self._log(f"$ {' '.join(cmd)}")
        if self.dry_run:
            return CommandResult(exit_code=0, stdout="", stderr="")
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            input=stdin_data,
            # No piped input → child stdin is /dev/null: an unexpected
            # interactive prompt fails fast on EOF instead of hanging the
            # installer forever.
            stdin=None if stdin_data is not None else subprocess.DEVNULL,
        )
        merged = (proc.stdout + proc.stderr).splitlines()
        for line in merged:
            self._log(line)
        if check and proc.returncode != 0:
            raise InstallError(
                f"Command failed (exit {proc.returncode}): {' '.join(cmd)}",
                merged[-TAIL_LINES:],
            )
        return CommandResult(proc.returncode, proc.stdout, proc.stderr)

    def run_streaming(
        self,
        cmd: list[str],
        check: bool = True,
        on_line: Optional[Callable[[str], None]] = None,
    ) -> CommandResult:
        """Execute (or capture in dry-run) a long-running command with live output.

        stdout and stderr are merged; every line is appended to the log file,
        passed to the optional ``on_line`` callback (live TUI view), and kept
        in a tail buffer that ``InstallError`` exposes on failure.
        """
        self.executed.append(list(cmd))
        self._log(f"$ {' '.join(cmd)}")
        if self.dry_run:
            return CommandResult(exit_code=0, stdout="", stderr="")

        proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
            # Long-running commands must never block on a prompt: /dev/null
            # stdin makes an unexpected interactive read abort on EOF.
            stdin=subprocess.DEVNULL,
        )
        tail: list[str] = []
        try:
            for raw in proc.stdout:  # type: ignore[union-attr]
                line = raw.rstrip("\n")
                tail.append(line)
                self._log(line)
                if on_line is not None:
                    on_line(line)
            rc = proc.wait()
        except BaseException:
            proc.kill()
            proc.wait()
            raise
        if check and rc != 0:
            raise InstallError(
                f"Command failed (exit {rc}): {' '.join(cmd)}",
                tail[-TAIL_LINES:],
            )
        return CommandResult(rc, "", "")

    def run_readonly(self, cmd: list[str], check: bool = False) -> CommandResult:
        """Execute a read-only inspection command for real (never captured).

        Safe to call even in dry-run: lsblk, /proc reads, sysfs checks do not
        mutate anything.
        """
        proc = subprocess.run(cmd, capture_output=True, text=True, stdin=subprocess.DEVNULL)
        if check and proc.returncode != 0:
            raise InstallError(
                f"Read-only command failed (exit {proc.returncode}): {' '.join(cmd)}\n"
                f"stderr: {proc.stderr}"
            )
        return CommandResult(proc.returncode, proc.stdout, proc.stderr)
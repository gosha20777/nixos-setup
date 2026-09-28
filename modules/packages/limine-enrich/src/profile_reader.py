"""Interacts with the NixOS profile system to read timestamps and boot notes."""

import datetime
import os
from typing import Tuple


def get_profile_info(gen_number: str) -> Tuple[str, str, str]:
    """Retrieve timestamp and human note for a given NixOS system generation.

    Returns:
        (date_str, full_date, note_str)
        e.g. ("28.09 12:00", "2026-09-28", "kernel upgrade")
    """
    profile_path = f"/nix/var/nix/profiles/system-{gen_number}-link"
    date_str = ""
    full_date = ""
    note_str = "system update"

    if os.path.exists(profile_path):
        try:
            st = os.lstat(profile_path)
            dt = datetime.datetime.fromtimestamp(st.st_mtime)
            date_str = dt.strftime("%d.%m %H:%M")
            full_date = dt.strftime("%Y-%m-%d")
        except Exception:
            pass

        note_file = os.path.join(profile_path, "etc/boot-note")
        if os.path.exists(note_file):
            try:
                with open(note_file, "r", encoding="utf-8") as nf:
                    n = nf.read().strip()
                    if n:
                        note_str = n
            except Exception:
                pass

    return date_str, full_date, note_str

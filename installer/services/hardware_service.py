"""Hardware discovery: disks, UEFI firmware mode, RAM."""

import json
import re
from pathlib import Path

from installer.models import DiskInfo
from installer.services.executor import CommandExecutor


def list_disks(executor: CommandExecutor) -> list[DiskInfo]:
    """List physical disks from lsblk JSON, excluding zram and loop devices."""
    result = executor.run_readonly(
        ["lsblk", "-J", "-o", "NAME,SIZE,MODEL,TRAN,RM,TYPE"]
    )
    data = json.loads(result.stdout)
    disks: list[DiskInfo] = []
    for entry in data.get("blockdevices", []):
        if entry.get("type") != "disk":
            continue
        # zram/loop devices have model=None — skip
        if entry.get("model") is None:
            continue
        disks.append(DiskInfo.from_lsblk_entry(entry))
    return disks


def check_uefi() -> bool:
    """True when booted in UEFI mode (sysfs firmware directory present)."""
    return Path("/sys/firmware/efi").exists()


def get_ram_gb() -> float:
    """Total physical RAM in GiB from /proc/meminfo MemTotal (kB)."""
    meminfo = Path("/proc/meminfo").read_text()
    match = re.search(r"^MemTotal:\s+(\d+)\s+kB", meminfo, re.MULTILINE)
    if match is None:
        return 0.0
    return int(match.group(1)) / 1024 / 1024

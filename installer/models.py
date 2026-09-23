"""Data models for NixOS Installer."""

import re
from dataclasses import dataclass
from typing import Optional


@dataclass
class DiskInfo:
    """Information about a storage block device."""
    path: str
    model: str
    size_gb: float
    is_nvme: bool = False
    is_removable: bool = False

    @classmethod
    def from_lsblk_entry(cls, entry: dict) -> "DiskInfo":
        """Build a DiskInfo from a single lsblk -J blockdevice entry.

        Size strings like ``"476.9G"`` are parsed with T/G/M suffixes;
        unknown formats fall back to 0.0.
        """
        return cls(
            path=f"/dev/{entry['name']}",
            model=entry.get("model") or "",
            size_gb=cls._parse_size(entry.get("size", "")),
            is_nvme=entry.get("tran") == "nvme",
            is_removable=bool(entry.get("rm", False)),
        )

    @staticmethod
    def _parse_size(size: str) -> float:
        multipliers = {"T": 1024.0, "G": 1.0, "M": 1.0 / 1024}
        match = re.fullmatch(r"([0-9.]+)([TGM])", size)
        if match is None:
            return 0.0
        return float(match.group(1)) * multipliers[match.group(2)]

    @property
    def display_label(self) -> str:
        bus = "NVMe" if self.is_nvme else "SATA/Other"
        removable = " [USB/Removable]" if self.is_removable else ""
        return f"{self.path}  {self.model} ({self.size_gb:.1f} GB, {bus}){removable}"


@dataclass
class HostInfo:
    """Information about a candidate NixOS host in the flake."""
    name: str
    description: str
    arch: str
    boot_mode: str
    disko_layout: str

    @property
    def display_label(self) -> str:
        return f"{self.name} — {self.description} ({self.arch}, {self.boot_mode})"


@dataclass
class InstallConfig:
    """Final configuration for deployment."""
    target_host: Optional[HostInfo] = None
    target_disk: Optional[DiskInfo] = None
    age_master_key: str = ""
    username: str = "gosha20777"
    repo_dest_path: str = "~/Projects/nixos-setup"
    dry_run: bool = True

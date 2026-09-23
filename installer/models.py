"""Data models for NixOS Installer."""

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

"""Target host discovery from the repository hosts/ directory."""

import json
from pathlib import Path
import subprocess

from installer.models import HostInfo


def query_host_config(repo_root: Path, host_name: str) -> dict:
    """Query live host settings directly from Nix flake evaluation if available."""
    expr = (
        'c: { '
        'timezone = c.time.timeZone or "UTC"; '
        'location = c.systemSettings.location or "не настроено"; '
        'layouts = c.home-manager.users.${c.systemSettings.username or "gosha20777"}.programs.niri.settings.input.keyboard.xkb.layout or "us"; '
        '}'
    )
    try:
        proc = subprocess.run(
            [
                "nix",
                "eval",
                "--json",
                f"path:{repo_root}#nixosConfigurations.{host_name}.config",
                "--apply",
                expr,
            ],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if proc.returncode == 0:
            return json.loads(proc.stdout)
    except Exception:
        pass
    return {}
def discover_hosts(repo_root: Path) -> list[HostInfo]:
    """Discover NixOS host profiles by scanning hosts/ subdirectories.

    Boot mode is inferred from the Disko layout imported in the host's
    default.nix: ``btrfs-uefi.nix`` → UEFI, ``btrfs-bios.nix`` → BIOS.
    Conservative fallback is BIOS if neither layout is referenced.
    """
    hosts_dir = repo_root / "hosts"
    hosts: list[HostInfo] = []
    if not hosts_dir.exists():
        return hosts
    for entry in sorted(hosts_dir.iterdir()):
        if not entry.is_dir():
            continue
        default_nix = entry / "default.nix"
        content = default_nix.read_text() if default_nix.exists() else ""
        if "btrfs-uefi.nix" in content:
            boot_mode = "UEFI"
            disko_layout = "btrfs-uefi"
        else:
            boot_mode = "BIOS"
            disko_layout = "btrfs-bios"
        meta = query_host_config(repo_root, entry.name)
        hosts.append(
            HostInfo(
                name=entry.name,
                description=f"NixOS host {entry.name}",
                arch="x86_64-linux",
                boot_mode=boot_mode,
                disko_layout=disko_layout,
                timezone=meta.get("timezone", "Europe/Berlin"),
                weather_location=meta.get("location", "Würzburg, Germany"),
                keyboard_layouts=meta.get("layouts", "us, ru, de"),
            )
        )
    return hosts

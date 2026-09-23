"""Target host discovery from the repository hosts/ directory."""

from pathlib import Path

from installer.models import HostInfo


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
        hosts.append(
            HostInfo(
                name=entry.name,
                description=f"NixOS host {entry.name}",
                arch="x86_64-linux",
                boot_mode=boot_mode,
                disko_layout=disko_layout,
            )
        )
    return hosts

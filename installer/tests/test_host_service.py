"""Tests for HostService: host discovery from hosts/ directory."""

from pathlib import Path

from installer.services.host_service import discover_hosts


def _make_repo(tmp_path: Path) -> Path:
    """Build a minimal repo tree: hosts/thinkpad (UEFI) + hosts/dev (BIOS)."""
    hosts = tmp_path / "hosts"
    thinkpad = hosts / "thinkpad"
    thinkpad.mkdir(parents=True)
    (thinkpad / "default.nix").write_text(
        "imports = [ ../../modules/disko/btrfs-uefi.nix ];"
    )
    dev = hosts / "dev"
    dev.mkdir()
    (dev / "default.nix").write_text(
        "imports = [ ../../modules/disko/btrfs-bios.nix ];"
    )
    # common.nix is a FILE — must not be picked up as a host
    (hosts / "common.nix").write_text("{ }: { }")
    return tmp_path


class TestDiscoverHosts:
    def test_discovers_both_hosts(self, tmp_path: Path):
        repo = _make_repo(tmp_path)

        hosts = discover_hosts(repo)

        assert [h.name for h in hosts] == ["dev", "thinkpad"]

    def test_boot_mode_inferred_from_disko_layout(self, tmp_path: Path):
        repo = _make_repo(tmp_path)

        hosts = {h.name: h for h in discover_hosts(repo)}

        assert hosts["thinkpad"].boot_mode == "UEFI"
        assert hosts["thinkpad"].disko_layout == "btrfs-uefi"
        assert hosts["dev"].boot_mode == "BIOS"
        assert hosts["dev"].disko_layout == "btrfs-bios"

    def test_arch_is_x86_64(self, tmp_path: Path):
        repo = _make_repo(tmp_path)

        hosts = discover_hosts(repo)

        assert all(h.arch == "x86_64-linux" for h in hosts)

    def test_missing_hosts_dir_returns_empty(self, tmp_path: Path):
        hosts = discover_hosts(tmp_path)

        assert hosts == []

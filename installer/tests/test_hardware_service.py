"""Tests for HardwareService: lsblk JSON parsing and pre-flight checks."""

from pathlib import Path

import pytest

from installer.services.executor import CommandExecutor, CommandResult
from installer.services.hardware_service import list_disks

FIXTURE = Path(__file__).parent / "fixtures" / "lsblk.json"


def _executor_with_fixture() -> CommandExecutor:
    executor = CommandExecutor(dry_run=True)
    fixture_data = FIXTURE.read_text()

    def fake_readonly(cmd):
        return CommandResult(exit_code=0, stdout=fixture_data, stderr="")

    executor.run_readonly = fake_readonly  # type: ignore[method-assign]
    return executor


class TestListDisks:
    def test_parses_fixture_excluding_zram(self):
        disks = list_disks(_executor_with_fixture())

        # zram0 (model=None) must be excluded
        assert len(disks) == 2

    def test_nvme_disk_flags(self):
        disks = list_disks(_executor_with_fixture())

        nvme = next(d for d in disks if d.path == "/dev/nvme0n1")
        assert nvme.is_nvme is True
        assert nvme.is_removable is False
        assert nvme.model == "SAMSUNG MZVLB512HBJQ-000L7"

    def test_usb_disk_flags(self):
        disks = list_disks(_executor_with_fixture())

        usb = next(d for d in disks if d.path == "/dev/sda")
        assert usb.is_nvme is False
        assert usb.is_removable is True

    def test_sizes_parsed_from_suffix_strings(self):
        disks = list_disks(_executor_with_fixture())

        sizes = {d.path: d.size_gb for d in disks}
        assert sizes["/dev/nvme0n1"] == pytest.approx(476.9)
        assert sizes["/dev/sda"] == pytest.approx(32.0)

"""Tests for InstallPipeline execution order."""

from pathlib import Path

from installer.models import HostInfo, InstallConfig
from installer.progress import InstallPipeline
from installer.services.executor import CommandExecutor


def test_pipeline_order_provisions_secrets_before_nixos_install():
    executor = CommandExecutor(dry_run=True)
    cfg = InstallConfig()
    cfg.target_host = HostInfo(
        name="pc",
        description="PC",
        arch="x86_64-linux",
        boot_mode="UEFI",
        disko_layout="hosts/pc/disko.nix",
    )
    cfg.age_master_key = "AGE-SECRET-KEY-1TEST"
    cfg.user_password = "testpassword"

    pipeline = InstallPipeline(executor, Path("/etc/iso/repo"), cfg)
    assert pipeline.run() is True

    # Order verification:
    # 1. disko (creates mounts in /mnt)
    # 2. secrets_service.provision (writes keys.txt to /mnt/home/... before nixos-install)
    # 3. nixos-install (can now read keys.txt during activation)
    # 4. chpasswd (sets user password)
    # 5. repo deployment
    cmd_names = [cmd[0] for cmd in executor.executed]
    assert cmd_names[0] == "disko"
    assert cmd_names[1] == "install"
    assert executor.executed[1][-1].endswith(".config/sops/age/keys.txt")
    assert cmd_names[2] == "nixos-install"
    assert cmd_names[3] == "chroot"
    assert cmd_names[4] == "install"  # install -d Projects

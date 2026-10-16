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
    # 3. install -d -m 700 /mnt/home/gosha20777 && chown -R 1000:100 /mnt/home/gosha20777
    #    (fixes root-owned subvolume mountpoints and .config before Home Manager runs)
    # 4. nixos-install (can now read keys.txt and write to ~/.config during activation)
    # 5. chpasswd (sets user password)
    # 6. repo deployment
    cmd_names = [cmd[0] for cmd in executor.executed]
    assert cmd_names[0] == "disko"
    assert cmd_names[1] == "install"
    assert executor.executed[1][-1].endswith(".config/sops/age/keys.txt")
    assert executor.executed[2] == ["install", "-d", "-m", "700", "/mnt/home/gosha20777"]
    assert executor.executed[3] == ["chown", "-R", "1000:100", "/mnt/home/gosha20777"]
    assert cmd_names[4] == "nixos-install"
    assert cmd_names[5] == "chroot"
    assert cmd_names[6] == "install"  # install -d Projects

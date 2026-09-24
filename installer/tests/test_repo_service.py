"""Tests for RepoService: flake deployment into the target system."""

import shutil
from pathlib import Path

from installer.services.repo_service import deploy
from installer.services.executor import CommandExecutor, InstallError

import installer.config as config


def _make_repo(tmp_path: Path) -> Path:
    src = tmp_path / "nixos-setup-src"
    (src / "hosts" / "thinkpad").mkdir(parents=True)
    (src / "flake.nix").write_text("{ }")
    (src / "hosts" / "thinkpad" / "default.nix").write_text("{ }")
    return src


class TestDryRun:
    def test_logs_install_cp_git_chown_in_order(self, tmp_path: Path):
        executor = CommandExecutor(dry_run=True)
        mount = tmp_path / "mnt"

        deploy(executor, tmp_path / "nixos-setup-src", mount, "gosha20777")

        assert len(executor.executed) == 4
        assert executor.executed[0][0] == "install"
        assert executor.executed[0][1] == "-d"
        assert executor.executed[1][0] == "cp"
        assert executor.executed[1][1] == "-r"
        # git runs while the copy is still root-owned; chown comes last.
        assert executor.executed[2][0] == "git"
        assert executor.executed[2][1] == "-C"
        assert config.GITHUB_ORIGIN in executor.executed[2]
        assert executor.executed[3][0] == "chown"
        assert executor.executed[3][1] == "-R"


class TestRealDeploy:
    def test_repo_copied_recursively(self, tmp_path: Path):
        executor = CommandExecutor(dry_run=False)
        src = _make_repo(tmp_path)
        mount = tmp_path / "mnt"
        mount.mkdir()

        try:
            deploy(executor, src, mount, "gosha20777")
        except InstallError:
            # chown requires root; on the Live CD the installer runs as root.
            # The copy step has already completed before chown, so the
            # filesystem assertions below still hold when running as a user.
            pass

        dest = mount / "home" / "gosha20777" / config.REPO_DEST
        assert (dest / "flake.nix").exists()
        assert (dest / "hosts" / "thinkpad" / "default.nix").exists()

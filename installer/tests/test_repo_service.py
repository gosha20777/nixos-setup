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
    def test_logs_install_cp_chmod_git_chown_in_order(self, tmp_path: Path):
        executor = CommandExecutor(dry_run=True)
        mount = tmp_path / "mnt"

        deploy(executor, tmp_path / "nixos-setup-src", mount, "gosha20777")

        assert len(executor.executed) == 5
        assert executor.executed[0][0] == "install"
        assert executor.executed[0][1] == "-d"
        assert executor.executed[1][0] == "cp"
        assert executor.executed[1][1] == "-rL"
        assert executor.executed[2] == [
            "chmod",
            "-R",
            "u+w",
            str(mount / "home" / "gosha20777" / config.REPO_DEST),
        ]
        # git runs while the copy is still root-owned; chown comes last.
        assert executor.executed[3][0] == "git"
        assert executor.executed[3][1] == "-C"
        assert config.GITHUB_ORIGIN in executor.executed[3]
        assert executor.executed[4][0] == "chown"
        assert executor.executed[4][1] == "-R"


class TestRealDeploy:
    def test_repo_copied_recursively_and_dereferenced(self, tmp_path: Path):
        executor = CommandExecutor(dry_run=False)
        real_src = _make_repo(tmp_path)
        symlink_src = tmp_path / "repo-symlink"
        symlink_src.symlink_to(real_src)
        mount = tmp_path / "mnt"
        mount.mkdir()

        try:
            deploy(executor, symlink_src, mount, "gosha20777")
        except InstallError:
            # chown requires root; on the Live CD the installer runs as root.
            # The copy step has already completed before chown, so the
            # filesystem assertions below still hold when running as a user.
            pass

        dest = mount / "home" / "gosha20777" / config.REPO_DEST
        assert dest.is_dir() and not dest.is_symlink()
        assert (dest / "flake.nix").exists()
        assert (dest / "hosts" / "thinkpad" / "default.nix").exists()


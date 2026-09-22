{
  config,
  lib,
  pkgs,
  ...
}:
{
  ############################################################
  # System-wide GUI applications
  ############################################################
  environment.systemPackages = with pkgs; [
    google-chrome
    vscode
    telegram-desktop
    nemo
    obsidian

    typora
    git
    curl
    wget
    unzip
    cryptsetup # handy for inspecting/managing the LUKS volume post-install

    # The backup service (modules/nixos/core/backup.nix) brings its own
    # restic; this is for driving the repo by hand — `restic snapshots`, and
    # `restic mount` to browse snapshots as directories. Both need
    # `--repo /mnt/backup/restic/<host>` and the password file (see the
    # Backups section in backup.md).
    restic
  ];
}

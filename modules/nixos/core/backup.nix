{
  config,
  lib,
  pkgs,
  ...
}:
{
  ############################################################
  # Backups — Time Machine-style, to an attached USB drive
  #
  # Shape: plug the drive in and it backs itself up; unplug and nothing
  # complains. restic gives versioned, deduplicated, encrypted snapshots, and
  # `restic mount` exposes every snapshot as a browsable directory tree — the
  # "go back in time" part of the Time Machine experience.
  #
  # The drive is found by FILESYSTEM LABEL, not device path, so any port or
  # enclosure works. Prepare a drive once with (destroys everything on it):
  #   sudo mkfs.ext4 -L timemachine /dev/sdX1
  #
  # The repo itself is encrypted by restic, so a lost or stolen drive leaks
  # nothing without the password — which is why the drive's own filesystem
  # doesn't need LUKS on top.
  #
  # On hosts where the drive is never attached (the dev VM) the hourly timer
  # still exists but the service exits cleanly on the
  # ConditionPathIsMountPoint check below — no failures, no alerts.
  ############################################################

  # noauto: don't try at boot, since the drive usually isn't there. nofail:
  # never block boot on it. The udev rule below is what actually mounts it,
  # on plug-in.
  fileSystems."/mnt/backup" = {
    device = "/dev/disk/by-label/timemachine";
    fsType = "ext4";
    options = [
      "nofail"
      "noauto"
    ];
  };

  # Plugging the drive in starts the mount unit. systemd translates
  # /mnt/backup into the unit name mnt-backup.mount.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_LABEL}=="timemachine", TAG+="systemd", ENV{SYSTEMD_WANTS}+="mnt-backup.mount"
  '';

  services.restic.backups.home = {
    repository = "/mnt/backup/restic/${config.networking.hostName}";
    passwordFile = "/etc/restic/home-password";
    # Create the repo on first run so there's no manual `restic init` step.
    initialize = true;
    paths = [ "/home/${config.systemSettings.username}" ];

    # Excludes. Measured 2026-09-05: $HOME was 31G, of which ~26G is
    # re-fetchable. What's left (~5G) is the genuinely irreplaceable part —
    # Documents, source, keys, ~/.claude, this flake.
    # Paths are relative to `paths` above (restic resolves them against the
    # backup set), so they stay correct whatever the username is.
    exclude = [
      # Model weights — large and re-downloadable.
      ".lmstudio"
      ".ollama"
      # Caches.
      ".cache"
      ".npm"
      ".local/share/Trash"
      ".zoom"
      # Chat/browser app state: big, and all of it re-syncs on next sign-in.
      # Signal in particular is re-linked from the phone, not restored.
      ".config/Signal"
      ".config/chromium"
      ".config/Slack"
      ".config/discord"
      "Downloads"
      # Build artefacts / dependency trees — rebuildable from the source
      # that IS backed up, and by far the worst churn-to-value ratio.
      "**/node_modules"
      "**/.venv"
      "**/__pycache__"
      "**/target"
      "**/.direnv"
      "*.pyc"
    ];

    # Hourly while the drive is attached. Persistent=true means a missed
    # window (laptop asleep, drive unplugged) runs once on the next mount
    # rather than being skipped silently.
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };

    # Time Machine-ish thinning: dense recent history, sparse older.
    pruneOpts = [
      "--keep-hourly 24"
      "--keep-daily 14"
      "--keep-weekly 8"
      "--keep-monthly 12"
    ];
  };

  systemd.services.restic-backups-home = {
    # Skip silently when the drive isn't attached. A Condition makes the unit
    # report "condition failed" and exit 0 — unlike RequiresMountsFor, which
    # would mark it failed and generate an alert every hour the drive is out.
    unitConfig.ConditionPathIsMountPoint = "/mnt/backup";
    # Back up as soon as the drive appears, not just on the hourly tick.
    wantedBy = [ "mnt-backup.mount" ];
  };
}

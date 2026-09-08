# System-level configuration for NixOS (mac-vm).
# User-level packages and dotfiles live in home.nix.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  ############################################################
  # Nix / nixpkgs
  ############################################################
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Default download buffer is 1 MiB, which fills constantly on big builds
  # (first install, niri/noctalia/claude-code together). 256 MiB silences the
  # "download buffer is full" warnings without meaningful memory cost.
  nix.settings.download-buffer-size = 256 * 1024 * 1024;
  # Weekly GC keeps /nix/store bounded; the 30-day window preserves enough
  # rollback headroom for a bad kernel or flake bump.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nixpkgs.config.allowUnfree = true; # lmstudio, typora, 1password, spotify
  system.stateVersion = "26.05";

  ############################################################
  # Boot — systemd-boot now; lanzaboote later (see SECURE BOOT)
  ############################################################
  boot.loader.systemd-boot.enable = true;
  # Cap /boot entries. The ESP is 1G; each generation writes a kernel + initrd
  # + entry. 10 entries ≈ 30 days of weekly rebuilds and keeps /boot well under
  # the fail line where nixos-rebuild switch dies mid-activation.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Plymouth boot splash screen
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];
  # FAT32 doesn't support Unix perms, so the ESP defaults to world-readable.
  # bootctl writes a kernel random-seed file in /boot/loader and (correctly)
  # complains: any local user could read the seed and learn things about the
  # kernel's entropy pool. Mount /boot with restrictive masks so files and
  # directories under the ESP are owner-only (root). Merges with the
  # /boot entry that nixos-generate-config wrote to hardware-configuration.nix.
  fileSystems."/boot".options = [
    "fmask=0077"
    "dmask=0077"
  ];

  ############################################################
  # Disk encryption + hibernation (suspend-to-disk)
  #
  # Default (Calamares install): ESP + LUKS-encrypted ext4 root. If you
  # selected the "Swap with Hibernate" option in Calamares, a swap
  # partition sized for the hibernation image is also created and
  # nixos-generate-config writes it into hardware-configuration.nix's
  # `swapDevices`. The kernel resumes from the first listed swap device
  # by default — no boot.resumeDevice needed. Verify after first boot
  # with `systemctl hibernate`.
  #
  # If Calamares' swap detection or hibernation doesn't pick up
  # automatically, uncomment one of these lines pointing at YOUR machine's
  # swap device (run `swapon --show` to find it):
  #
  #   boot.resumeDevice = "/dev/disk/by-uuid/<your-swap-uuid>";
  #
  # If you used INSTALL.md's manual LVM-on-LUKS appendix instead, the
  # stable LVM path is:
  #
  #   boot.resumeDevice = "/dev/vg/swap";

  # The per-host hibernation swap unlock and boot.resumeDevice are
  # machine-specific (LUKS UUIDs differ per disk), so they live in the host's
  # own module: hosts/<hostname>/default.nix. See hosts/README.md for how a
  # new machine sets them up.

  # Idle escalation timing (Noctalia in home.nix triggers the actions, via
  # programs.noctalia.settings.idle.behavior): lock @ 10 min, then
  # `systemctl suspend-then-hibernate` @ 15 min. That
  # suspends to RAM and, HibernateDelaySec later, wakes and hibernates to
  # disk — so hibernate lands at 3h 15m total idle. The long delay favors
  # quick lid-open resume for the common short-break case; hibernate still
  # catches the laptop before the battery drains overnight.
  systemd.sleep.settings.Sleep.HibernateDelaySec = 10800; # 3h

  # Closing the lid suspends to RAM, then hibernates HibernateDelaySec later —
  # the same suspend-then-hibernate escalation the idle timeout uses. Applies
  # on battery and AC (HandleLidSwitchExternalPower defaults to this value);
  # HandleLidSwitchDocked defaults to "ignore", so an external display keeps
  # the session alive with the lid shut.
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  ############################################################
  # SECURE BOOT (lanzaboote) — uncomment after install, see secure-boot.md
  ############################################################
  # environment.systemPackages = with pkgs; [ sbctl ]; # merge into the list below
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  # boot.lanzaboote = {
  #   enable = true;
  #   pkiBundle = "/var/lib/sbctl";
  # };

  ############################################################
  # Framework 13 AMD power & firmware
  ############################################################
  services.fwupd.enable = true;
  services.power-profiles-daemon.enable = true; # NOT tlp on Ryzen 7040
  services.tlp.enable = false;
  services.fstrim.enable = true;
  # Noctalia's battery widget (and any UPower consumer) needs the daemon
  # registered on the system bus; without it the shell logs
  # `org.freedesktop.DBus.Error.ServiceUnknown` and silently drops battery
  # state. power-profiles-daemon doesn't pull it in on its own.
  services.upower.enable = true;

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
    paths = [ "/home/gosha20777" ];

    # Excludes. Measured 2026-09-05: $HOME was 31G, of which ~26G is
    # re-fetchable. What's left (~5G) is the genuinely irreplaceable part —
    # Documents, source, keys, ~/.claude, this flake.
    exclude = [
      # Model weights — large and re-downloadable.
      "/home/gosha20777/.lmstudio"
      "/home/gosha20777/.ollama"
      # Caches.
      "/home/gosha20777/.cache"
      "/home/gosha20777/.npm"
      "/home/gosha20777/.local/share/Trash"
      "/home/gosha20777/.zoom"
      # Chat/browser app state: big, and all of it re-syncs on next sign-in.
      # Signal in particular is re-linked from the phone, not restored.
      "/home/gosha20777/.config/Signal"
      "/home/gosha20777/.config/chromium"
      "/home/gosha20777/.config/Slack"
      "/home/gosha20777/.config/discord"
      "/home/gosha20777/Downloads"
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

  ############################################################
  # Audio (PipeWire)
  ############################################################
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  ############################################################
  # Locale + timezone
  # America/New_York follows EST/EDT (DST-aware). en_US.UTF-8 gives
  # imperial measurement units, US paper sizes, etc.
  ############################################################
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  ############################################################
  # Networking, Bluetooth
  # networking.hostName is set per-host in hosts/<hostname>/default.nix.
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  ############################################################
  # niri + greetd (noctalia-greeter) login
  ############################################################
  programs.niri.enable = true;
  # niri-flake's `programs.niri.package` defaults to niri-stable (v25.08).
  # Pin to niri-unstable because Quickshell-based shells (Noctalia and the
  # ecosystem that shares its Wayland-protocol footprint) track niri's
  # latest, and the stable tag lags. Also disable the in-build cargo test
  # suite — those tests sometimes SIGABRT inside the Nix build sandbox
  # (filesystem assumptions that don't hold), even when the binary itself
  # works at runtime. We don't gain confidence by running niri's own tests
  # during our system build.
  programs.niri.package =
    (inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable).overrideAttrs
      (old: {
        doCheck = false;
      });

  # noctalia-greeter on tty1 — a Quickshell-based login screen that mirrors
  # Noctalia Shell's palette/wallpaper (imperative sync via Settings → Shell →
  # Security → Noctalia Greeter → Sync Now — see TODO.md). The greeter's
  # NixOS module sets services.greetd.enable + default_session.command with
  # mkDefault, so no explicit greetd block is needed here.
  #   - allow_empty_password: fprintd's PAM module answers the password
  #     prompt with an empty reply after a fingerprint match; without this
  #     the greeter rejects that reply as invalid credentials.
  #   - keyboard.layout: greeter runs before the session's input config, so
  #     the layout has to be told explicitly.
  programs.noctalia-greeter = {
    enable = true;
    settings = {
      auth.allow_empty_password = false;
      keyboard.layout = "us";
    };
  };

  # Polkit auth agent: defer to Noctalia's native polkit agent (enabled via
  # programs.noctalia.settings.shell.polkit_agent in home.nix) rather than
  # niri-flake's bundled polkit-kde-agent service. Two agents would race on the
  # org.freedesktop.PolicyKit1.AuthenticationAgent bus name; the upstream
  # plugin docs explicitly require the other agent to be disabled. Force
  # the unit off — niri-flake hard-codes `wantedBy = [ "niri.service" ]`
  # with no opt-out option, so this is the only knob.
  systemd.user.services.niri-flake-polkit.enable = lib.mkForce false;

  # Tear out GNOME left behind by the Calamares base install. Harmless
  # to keep on if you used the manual install path (nothing to disable).
  services.xserver.enable = false;
  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = false;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  services.gnome.gnome-keyring.enable = true;
  services.accounts-daemon.enable = true;
  programs.dconf.enable = true;

  # gvfs — the GNOME virtual filesystem daemon. Nautilus (in
  # environment.systemPackages) degrades quietly without it: no Trash, no
  # network mounts (SMB/SFTP), no MTP for phones. Nothing errors, the
  # features are simply absent from the UI, so this is easy to miss.
  services.gvfs.enable = true;

  ############################################################
  # Shells (Fish primary, Bash standard)
  ############################################################
  programs.bash.enable = true;
  programs.fish.enable = true;
  environment.shells = [
    pkgs.fish
    pkgs.bash
  ];
  ############################################################
  # Non-Nix dynamic binaries (mise / pre-built toolchains)
  #
  # mise downloads upstream pre-built binaries — node from nodejs.org,
  # go from go.dev, python from python-build-standalone — that are all
  # linked against /lib64/ld-linux-x86-64.so.2 and a handful of common
  # shared libraries. NixOS doesn't have an FHS, so without a shim those
  # binaries fail to launch with "No such file or directory" pointing at
  # the linker. `programs.nix-ld` installs a stub at the canonical linker
  # path and uses the `libraries` list as the search path for the .so
  # files those binaries dlopen at runtime.
  #
  # Scope is intentional: this is only for mise-managed toolchains.
  # Everything Nix-native (everything in pkgs / home.packages) ignores
  # nix-ld and resolves through the usual store paths.
  ############################################################
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++ / libgcc_s — node's V8, many node native modules
      zlib # python zlib, node zlib bindings, gzipped tarballs unpacked at runtime
      openssl # python _ssl, node tls
      libffi # python ctypes
      ncurses # python _curses, readline backend
      readline # python readline
      bzip2 # python _bz2
      xz # python _lzma
      sqlite # python sqlite3
    ];
  };

  ############################################################
  # Containers + local LLM serving
  ############################################################
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  ############################################################
  # User
  ############################################################

  users.users.gosha20777 = {
    isNormalUser = true;
    description = "gosha20777";
    shell = pkgs.fish;
    initialPassword = "20777";
    # To use a hashed password instead, generate one with:
    #   mkpasswd -m sha-512 "20777"
    # and replace initialPassword with:
    #   hashedPassword = "...";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "video"
      "input"
    ];
  };

  ############################################################
  # System-wide GUI applications
  ############################################################
  environment.systemPackages = with pkgs; [
    google-chrome
    vscode
    telegram-desktop
    nautilus
    obsidian

    typora
    git
    curl
    wget
    unzip
    cryptsetup # handy for inspecting/managing the LUKS volume post-install

    # The backup service brings its own restic; this is for driving the repo
    # by hand — `restic snapshots`, and `restic mount` to browse snapshots as
    # directories. Both need `--repo /mnt/backup/restic/<host>` and the
    # password file (see the Backups section above).
    restic
  ];

  ############################################################
  # Firmware blobs, fonts
  ############################################################
  hardware.enableRedistributableFirmware = true;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-color-emoji
  ];
}

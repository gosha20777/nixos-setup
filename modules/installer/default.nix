# Live installer ISO — boots into the full shared desktop and runs the
# Python installer. NOT a target machine: this module lives outside hosts/
# (nixosConfigurations.live-*, built by mkLive in flake.nix) so that
# host auto-discovery only ever offers target machines.
#
# Hardware support is inherited from the installation-cd-minimal profile
# (scan/detected + not-detected: all kernel drivers, NetworkManager);
# graphics come from Mesa in the shared closure (Intel/AMD iGPU — the
# NVIDIA dGPU is host-specific and is fetched at install time instead).
{
  config,
  pkgs,
  lib,
  repoRoot, # flake root path (specialArgs from mkLive)
  ...
}:
{
  imports = [
    # Live desktop = the shared system + home module trees, exactly like a
    # real host — this IS the final OS experience.
    ../../hosts/common.nix
  ];

  networking.hostName = "live";
  # Fix font rendering in Live ISO: installation-cd-minimal sets mkOverride 500 false,
  # which disables fontconfig entirely. Force it on so JetBrainsMono Nerd Font resolves.
  fonts.fontconfig.enable = lib.mkForce true;

  # Disable sops in live session (no Age key present on boot). This allows Home Manager
  # activation to complete cleanly without aborting, ensuring wallpapers and starship seed.
  systemSettings.sops.enable = false;

  # Home Manager live tweaks: auto-start installer, set scale, and fish hint
  home-manager.users.${config.systemSettings.username} = {
    programs.niri.settings = {
      spawn-at-startup = [
        { argv = [ "kitty" "-e" "nixos-installer" ]; }
      ];
      outputs."eDP-1".scale = 1.25;
      outputs."Virtual-1".scale = 1.25;
    };

    programs.fish.interactiveShellInit = ''
      set -g fish_greeting "🌲 NixOS Everforest Live — для запуска установщика выполните: nixos-installer"
    '';
  };

  # Passwordless live user for desktop autologin (installation-device style)
  users.users.${config.systemSettings.username}.initialHashedPassword = "";

  # Autologin straight into niri (no greeter prompt in live mode)
  services.greetd.settings.initial_session = {
    command = "niri-session";
    user = config.systemSettings.username;
  };

  # Ensure Home Manager activation completes before greetd starts the session,
  # preventing races where niri/Noctalia launch before themes, icons, and wallpapers exist.
  systemd.services.greetd = {
    after = [ "home-manager-${config.systemSettings.username}.service" ];
    wants = [ "home-manager-${config.systemSettings.username}.service" ];
  };
  environment.systemPackages =
    let
      installerPython = pkgs.python3.withPackages (ps: [ ps.rich ]);
    in
    with pkgs;
    [
      disko
      git
      age
      sops
      installerPython

      # TUI installer launcher — runs the baked flake repo's installer app
      (writeShellScriptBin "nixos-installer" ''
        exec ${installerPython}/bin/python3 /etc/iso/repo/installer/main.py --repo /etc/iso/repo "$@"
      '')
    ];

  # Bake the flake repository (including installer/) into the ISO
  environment.etc."iso/repo".source = repoRoot;

  # zstd instead of the default xz: much faster ISO builds, slightly larger image
  isoImage.squashfsCompression = "zstd -Xcompression-level 3";
}

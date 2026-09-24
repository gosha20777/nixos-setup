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

  # Passwordless live user for desktop autologin (installation-device style)
  users.users.${config.systemSettings.username}.initialHashedPassword = "";

  # Autologin straight into niri (no greeter prompt in live mode)
  services.greetd.settings.initial_session = {
    command = "niri-session";
    user = config.systemSettings.username;
  };

  environment.systemPackages = with pkgs; [
    disko
    git
    age
    sops
    (python3.withPackages (ps: [ ps.rich ]))

    # TUI installer launcher — runs the baked flake repo's installer app
    (pkgs.writeShellScriptBin "nixos-installer" ''
      exec python3 /etc/iso/repo/installer/main.py --repo /etc/iso/repo "$@"
    '')
  ];

  # Bake the flake repository (including installer/) into the ISO
  environment.etc."iso/repo".source = repoRoot;

  # zstd instead of the default xz: much faster ISO builds, slightly larger image
  isoImage.squashfsCompression = "zstd -Xcompression-level 3";
}

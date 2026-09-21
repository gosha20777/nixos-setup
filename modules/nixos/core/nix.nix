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
}

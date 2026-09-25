{
  config,
  pkgs,
  ...
}:
{
  ############################################################
  # Nix Helper (nh) CLI & automated garbage collection
  ############################################################
  programs.nh = {
    enable = true;

    # Point directly to this repository with host attribute pinned to networking.hostName.
    # Enables simple `nh os switch` without manual target or path flags.
    flake = "/home/${config.systemSettings.username}/Projects/nixos-setup#${config.networking.hostName}";

    clean = {
      enable = true;
      dates = "daily";
      extraArgs = "--keep 3";
    };
  };
}

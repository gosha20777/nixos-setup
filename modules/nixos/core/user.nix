# The user account + its home-manager base. The username comes from
# systemSettings (modules/core/settings.nix) so every module stays
# name-agnostic.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  users.users.${config.systemSettings.username} = {
    isNormalUser = true;
    description = config.systemSettings.username;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "video"
      "input"
    ];
  };

  # Base home-manager configuration for the user. Per-host home overrides
  # live in hosts/<name>/home.nix, attached via
  # home-manager.users.<name>.imports in the host's default.nix.
  home-manager.users.${config.systemSettings.username} = {
    home.username = config.systemSettings.username;
    home.homeDirectory = "/home/${config.systemSettings.username}";
    home.stateVersion = "26.05";
    programs.home-manager.enable = true;
  };
}

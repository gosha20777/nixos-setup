# Desktop role — NOT auto-imported. Include explicitly in a desktop
# host's default.nix:
#   imports = [ ../../modules/nixos/roles/desktop.nix ];
#
# The stationary-machine counterpart of roles/laptop.nix: firmware updates
# and periodic SSD trim, with no lid/hibernate/power-daemon logic.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.fwupd.enable = true;
  services.fstrim.enable = true;

  home-manager.users.${config.systemSettings.username}.my.desktop.idle.profile =
    lib.mkDefault "desktop";
}

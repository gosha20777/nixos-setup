# Workstation / 24/7 Server role — NOT auto-imported. Include explicitly in
# a workstation host's default.nix:
#   imports = [ ../../modules/nixos/roles/workstation.nix ];
#
# Stationary always-on machine: firmware updates, periodic SSD trim,
# system-wide sleep/suspend targets disabled (24/7 SSH/compute availability),
# and display-only idle lock (10m lock + DPMS off, never suspends).
{
  config,
  lib,
  ...
}:
{
  services.fwupd.enable = true;
  services.fstrim.enable = true;

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };

  home-manager.users.${config.systemSettings.username}.my.desktop.idle.profile =
    lib.mkDefault "workstation";
}

# Laptop role — NOT auto-imported. Include explicitly in a laptop host's
# default.nix:
#   imports = [ ../../modules/nixos/roles/laptop.nix ];
#
# Carries everything that only makes sense on battery-powered, lid-closable
# hardware: suspend-then-hibernate escalation and the power daemons.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Closing the lid suspends to RAM (S3 deep sleep) with immediate fast wake.
  # Applies equally on battery and AC.
  # HandleLidSwitchDocked is "ignore", so an external display keeps
  # the session alive with the lid shut (clamshell mode).
  services.logind.settings.Login.HandleLidSwitch = "suspend";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "suspend";
  services.logind.settings.Login.HandleLidSwitchDocked = "ignore";

  services.fwupd.enable = true;
  # power-profiles-daemon for native Linux power profile management (EPP/platform_profile).
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
  # Noctalia's battery widget (and any UPower consumer) needs the daemon
  # registered on the system bus; without it the shell logs
  # `org.freedesktop.DBus.Error.ServiceUnknown` and silently drops battery
  # state. power-profiles-daemon doesn't pull it in on its own.
  services.upower.enable = true;
}

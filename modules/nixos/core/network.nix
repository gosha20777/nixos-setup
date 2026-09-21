{
  config,
  lib,
  pkgs,
  ...
}:
{
  ############################################################
  # Networking, Bluetooth
  # networking.hostName is set per-host in hosts/<hostname>/default.nix.
  ############################################################
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
}

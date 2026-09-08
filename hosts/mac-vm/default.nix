# Per-host module for mac-vm (UTM on Apple Silicon).
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "mac-vm";

  # UTM / QEMU guest integrations (clipboard sharing, dynamic resolution, time sync)
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}

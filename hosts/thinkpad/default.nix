# Per-host module for thinkpad (Lenovo ThinkPad P1 Gen 2).
{ config, ... }:
{
  imports = [
    ../common.nix
    ../../modules/disko/btrfs-uefi.nix
  ];

  networking.hostName = "thinkpad";
  nixpkgs.hostPlatform = "x86_64-linux";

  # Disko device target for NVMe SSD
  disko.devices.disk.main.device = "/dev/nvme0n1";

  home-manager.users.${config.systemSettings.username}.imports = [ ./home.nix ];
}

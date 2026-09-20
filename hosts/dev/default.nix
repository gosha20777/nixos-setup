# Per-host module for dev (Gnome Boxes / QEMU on x86_64).
{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "dev";

  # Gnome Boxes / QEMU guest integrations (clipboard sharing, dynamic resolution, time sync)
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # The Gnome Boxes VM boots Legacy BIOS and its disk has no ESP (single
  # btrfs partition from the Calamares "Erase disk" install), so the shared
  # systemd-boot/UEFI config cannot work here. Install GRUB into the MBR
  # of /dev/vda instead.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub = {
    enable = lib.mkForce true;
    device = "/dev/vda";
    configurationLimit = 10;
  };

  # Enable OpenSSH daemon for SSH access from host
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.gosha20777.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHz1i0hWB0f6oP3+EkA0EodjJrp5R3P9F8rC5sivM1py gosha20777@pc"
  ];
}

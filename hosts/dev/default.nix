# Per-host module for dev (Gnome Boxes / QEMU on x86_64).
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "dev";

  # Gnome Boxes / QEMU guest integrations (clipboard sharing, dynamic resolution, time sync)
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

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

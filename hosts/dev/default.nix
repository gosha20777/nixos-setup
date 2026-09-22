# Per-host module for dev (Gnome Boxes / QEMU on x86_64).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../common.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "dev";

  # Ensure Mesa exposes OpenGL 3.3 in the virgl VM (the virtual GPU reports
  # a lower core profile than niri/Quickshell request).
  environment.sessionVariables = {
    MESA_GL_VERSION_OVERRIDE = "3.3";
    MESA_GLSL_VERSION_OVERRIDE = "330";
  };

  # Gnome Boxes / QEMU guest integrations (clipboard sharing, dynamic resolution, time sync)
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  # Passwordless sudo for dev VM to allow seamless automated rebuilds
  security.sudo.wheelNeedsPassword = false;

  # The Gnome Boxes VM boots Legacy BIOS and its disk has no ESP (single
  # btrfs partition from the Calamares "Erase disk" install), so the shared
  # systemd-boot/UEFI config (modules/nixos/core/boot.nix) cannot work here.
  # Install GRUB into the MBR of /dev/vda instead.
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

  # Per-host home overrides — everything VM-specific at the user level
  # (SPICE session agent, output mode) lives in ./home.nix and merges on
  # top of the shared tree (modules/home) auto-imported via common.nix.
  home-manager.users.${config.systemSettings.username}.imports = [ ./home.nix ];
}

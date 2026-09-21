# Per-host module for dev (Gnome Boxes / QEMU on x86_64).
{ lib, pkgs, ... }:
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

  # VM-specific home-manager settings merge into the shared home.nix via
  # home-manager.users.<user> (the HM NixOS module is loaded in flake.nix).

  # SPICE session agent: vdagentd (enabled above) only exposes the virtio
  # channel; the per-session agent is what gives the guest a client-side
  # cursor (no duplicated host cursor) and a shared clipboard. niri /
  # wlroots compositors never spawn it themselves — GNOME does, we don't —
  # so tie it to the graphical session explicitly.
  home-manager.users.gosha20777 = {
    systemd.user.services.spice-vdagent = {
      Unit = {
        Description = "SPICE session agent (cursor, clipboard sharing)";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Pin the VM output to the host's 1920x1080 panel. niri (like all
    # wlroots compositors) does not implement SPICE-agent dynamic resolution,
    # so the mode can't follow the viewer window — set it statically instead.
    programs.niri.settings.outputs."Virtual-1".mode = {
      width = 1920;
      height = 1080;
    };
  };
}

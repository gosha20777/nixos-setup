{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  ############################################################
  # Boot — systemd-boot now; lanzaboote later (see SECURE BOOT)
  ############################################################
  boot.loader.systemd-boot.enable = true;
  # Cap /boot entries. The ESP is 1G; each generation writes a kernel + initrd
  # + entry. 10 entries ≈ 30 days of weekly rebuilds and keeps /boot well under
  # the fail line where nixos-rebuild switch dies mid-activation.
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Plymouth boot splash screen
  boot.plymouth = {
    enable = true;
    theme = "bgrt";
  };
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];
  # NOTE: the ESP-only /boot fmask/dmask options used to live here, but a
  # /boot mount only exists on UEFI hosts with an ESP. Hosts booting Legacy
  # BIOS with GRUB have no /boot entry at all; when a UEFI host lands, set
  # those options in its hosts/<name>/ module next to its
  # fileSystems."/boot" definition.

  ############################################################
  # SECURE BOOT (lanzaboote) — uncomment after install, see secure-boot.md
  # The module itself is wired in hosts/common.nix (commented there, together
  # with the input in flake.nix).
  ############################################################
  # environment.systemPackages = with pkgs; [ sbctl ]; # merge into the list in apps.nix
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  # boot.lanzaboote = {
  #   enable = true;
  #   pkiBundle = "/var/lib/sbctl";
  # };
}

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
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openconnect ];
    ensureProfiles.profiles = {
      Uni-Wuerzburg = {
        connection = {
          id = "Uni-Wuerzburg";
          type = "vpn";
          autoconnect = false;
        };
        vpn = {
          service-type = "org.freedesktop.NetworkManager.openconnect";
          gateway = "vpngw.uni-wuerzburg.de";
          usergroup = "Standard (MFA)";
          protocol = "anyconnect";
          useragent = "AnyConnect";
        };
      };
    };
  };

  programs.nm-applet.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
}

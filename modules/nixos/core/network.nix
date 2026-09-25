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
          authtype = "password";
          autoconnect-flags = "0";
          certsigs-flags = "0";
          cookie-flags = "2";
          disable_udp = "no";
          enable_csd_trojan = "no";
          gateway = "vpngw.uni-wuerzburg.de";
          gateway-flags = "2";
          gwcert-flags = "2";
          lasthost-flags = "0";
          pem_passphrase_fsid = "no";
          prevent_invalid_cert = "no";
          protocol = "anyconnect";
          resolve-flags = "2";
          stoken_source = "disabled";
          useragent = "AnyConnect";
          xmlconfig-flags = "0";
        };
      };
    };
  };

  programs.nm-applet.enable = true;
  # NetworkManager-openconnect requires a system user for D-Bus policies and privilege separation
  users.users.nm-openconnect = {
    isSystemUser = true;
    group = "networkmanager";
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
}

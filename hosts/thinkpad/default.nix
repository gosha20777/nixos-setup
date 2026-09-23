# Per-host module for thinkpad (Lenovo ThinkPad P1 Gen 2).
{ config, ... }:
{
  imports = [
    ../common.nix
  ];

  networking.hostName = "thinkpad";
  nixpkgs.hostPlatform = "x86_64-linux";

  home-manager.users.${config.systemSettings.username}.imports = [ ./home.nix ];
}

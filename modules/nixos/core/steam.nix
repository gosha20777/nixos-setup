{ lib, config, ... }:

let
  cfg = config.my.apps.steam;
in
{
  options.my.apps.steam = {
    enable = lib.mkEnableOption "Steam and Gamemode";
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    programs.gamemode.enable = true;
  };
}

{
  config,
  lib,
  systemSettings,
  ...
}:
{
  sops = lib.mkIf systemSettings.sops.enable {
    defaultSopsFile = ../../../secrets/common.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}

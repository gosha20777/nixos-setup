{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../../secrets/common.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}

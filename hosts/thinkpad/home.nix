# Per-host home overrides for thinkpad
{ config, ... }:
{
  sops.secrets."id_ed25519" = {
    sopsFile = ../../secrets/thinkpad.yaml;
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };
}

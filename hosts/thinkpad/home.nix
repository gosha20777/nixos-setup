# Per-host home overrides for thinkpad
{ config, ... }:
{
  # Machine-specific SSH key from secrets/thinkpad.yaml
  sops.secrets."id_ed25519" = {
    sopsFile = ../../secrets/thinkpad.yaml;
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };

  # Built-in display configuration (15.6" 1920x1080 @ 60Hz)
  # Scale 1.30 per display-scaling.md calculation for optimal acuity/comfort
  programs.niri.settings.outputs."eDP-1" = {
    mode = {
      width = 1920;
      height = 1080;
    };
    scale = 1.3;
  };
}

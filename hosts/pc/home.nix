{ config, ... }:

{
  # Machine-specific SSH key from secrets/pc.yaml
  sops.secrets."id_ed25519" = {
    sopsFile = ../../secrets/pc.yaml;
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };

  # ── Display Configuration (24" 1920x1080) ──
  # Scale 1.30 per display-scaling.md biometric profile for 24" 1080p @ 50cm
  programs.niri.settings.outputs."HDMI-A-1" = {
    mode = {
      width = 1920;
      height = 1080;
    };
    scale = 1.3;
  };
}

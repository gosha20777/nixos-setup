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
  # Scale 1.40 for enlarged UI comfort per low-vision acuity model
  programs.niri.settings.outputs."eDP-1" = {
    mode = {
      width = 1920;
      height = 1080;
    };
    scale = 1.4;
  };

  # ── Hardware touchpad tuning (Synaptics TM3512-010 RMI4/I2C) ──
  # Calibrated for scale 1.40: reduces scroll speed to match MacBook 1:1 feel,
  # adds adaptive pointer acceleration for precise micro-control and quick flicks.
  programs.niri.settings.input.touchpad = {
    scroll-factor = 0.45;
    accel-profile = "adaptive";
    accel-speed = 0.15;
  };
}

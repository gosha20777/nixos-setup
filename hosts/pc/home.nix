{
  config,
  lib,
  pkgs,
  ...
}:

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

  # Disable generic lock in Noctalia; swayidle handles the cascade
  programs.noctalia.settings.idle.behavior.lock.enabled = lib.mkForce false;

  # ── Idle power management cascade (swayidle) ──
  # Desktop cascade (AC only, no battery checks):
  # 10 min: lock and power off monitors
  # 30 min: suspend to RAM
  services.swayidle.timeouts =
    let
      noctaliaBin = "${config.programs.noctalia.package}/bin/noctalia";
      niriBin = "${config.programs.niri.package}/bin/niri";
      systemctlBin = "${pkgs.systemd}/bin/systemctl";
    in
    [
      {
        timeout = 600;
        command = "${noctaliaBin} msg session lock && ${niriBin} msg action power-off-monitors";
        resumeCommand = "${niriBin} msg action power-on-monitors";
      }
      {
        timeout = 1800;
        command = "${systemctlBin} suspend";
      }
    ];
}

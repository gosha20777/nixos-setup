# Per-host home overrides for thinkpad
{
  config,
  lib,
  pkgs,
  ...
}:
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

  # Noctalia bar: add caffeine widget in center beside clock
  programs.noctalia.settings.bar.default.center = lib.mkForce [
    "cat"
    "clock"
    "caffeine"
    "audio_visualizer"
  ];

  # Disable generic 10-minute lock in Noctalia; swayidle below handles the 3-step cascade
  programs.noctalia.settings.idle.behavior.lock.enabled = lib.mkForce false;

  # ── Idle power management cascade (swayidle) ──
  # 3 чистых шага с динамической проверкой источника питания:
  # • На батарее: 1 мин приглушение -> 2.5 мин выключение экрана + lock -> 4 мин сон в ОЗУ
  # • От сети (AC): 3 мин приглушение -> 6 мин выключение экрана + lock -> 9 мин сон в ОЗУ
  services.swayidle.timeouts =
    let
      noctaliaBin = "${config.programs.noctalia.package}/bin/noctalia";
      niriBin = "${config.programs.niri.package}/bin/niri";
      brightnessctlBin = "${pkgs.brightnessctl}/bin/brightnessctl";
      systemctlBin = "${pkgs.systemd}/bin/systemctl";
      grepBin = "${pkgs.gnugrep}/bin/grep";
      isOnAc = "${grepBin} -qs 1 /sys/class/power_supply/*/online";
    in
    [
      # ── На батарее (Battery: агрессивный профиль) ──
      # 1 мин (60s): приглушение подсветки экрана до 20%
      {
        timeout = 60;
        command = "if ! ${isOnAc}; then ${brightnessctlBin} -s set 20%; fi";
        resumeCommand = "${brightnessctlBin} -r";
      }
      # 2.5 мин (150s): блокировка сессии и отключение дисплеев (DPMS off, 0W)
      {
        timeout = 150;
        command = "if ! ${isOnAc}; then ${noctaliaBin} msg session lock && ${niriBin} msg action power-off-monitors; fi";
        resumeCommand = "if ! ${isOnAc}; then ${niriBin} msg action power-on-monitors; fi";
      }
      # 4 мин (240s): глубокий сон в ОЗУ (S3 deep)
      {
        timeout = 240;
        command = "if ! ${isOnAc}; then ${systemctlBin} suspend; fi";
      }

      # ── От сети / зарядки (AC: комфортный профиль) ──
      # 3 мин (180s): приглушение подсветки экрана до 20%
      {
        timeout = 180;
        command = "if ${isOnAc}; then ${brightnessctlBin} -s set 20%; fi";
        resumeCommand = "${brightnessctlBin} -r";
      }
      # 6 мин (360s): блокировка сессии и отключение дисплеев (DPMS off, 0W)
      {
        timeout = 360;
        command = "if ${isOnAc}; then ${noctaliaBin} msg session lock && ${niriBin} msg action power-off-monitors; fi";
        resumeCommand = "if ${isOnAc}; then ${niriBin} msg action power-on-monitors; fi";
      }
      # 9 мин (540s): глубокий сон в ОЗУ (S3 deep)
      {
        timeout = 540;
        command = "if ${isOnAc}; then ${systemctlBin} suspend; fi";
      }
    ];
}

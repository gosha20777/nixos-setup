# swayidle — declarative idle power management profiles across all hosts.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.desktop.idle;

  noctaliaBin = "${config.programs.noctalia.package}/bin/noctalia";
  niriBin = "${config.programs.niri.package}/bin/niri";
  brightnessctlBin = "${pkgs.brightnessctl}/bin/brightnessctl";
  systemctlBin = "${pkgs.systemd}/bin/systemctl";
  grepBin = "${pkgs.gnugrep}/bin/grep";
  isOnAc = "${grepBin} -qs 1 /sys/class/power_supply/*/online";
in
{
  options.my.desktop.idle = {
    profile = lib.mkOption {
      type = lib.types.enum [
        "none"
        "laptop"
        "desktop"
        "workstation"
      ];
      default = "none";
      description = ''
        Idle power management profile driven by swayidle:
        - "none": no swayidle timeouts (falls back to Noctalia's 10m lock; used on dev VM / live ISO).
        - "laptop": 3-step battery (60s/150s/240s) + AC (180s/360s/540s) cascade with backlight dimming, lock + DPMS off, and suspend.
        - "desktop": 10m (600s) lock + DPMS off, 30m (1800s) suspend to RAM.
        - "workstation": 10m (600s) lock + DPMS off, never suspends (24/7 workstation).
      '';
    };
  };

  config = {
    # Disable generic lock in Noctalia whenever a swayidle timeout cascade is active
    programs.noctalia.settings.idle.behavior.lock.enabled = lib.mkIf (cfg.profile != "none") (
      lib.mkForce false
    );

    services.swayidle = {
      enable = true;
      events = {
        before-sleep = "${noctaliaBin} msg session lock";
      };

      timeouts =
        if cfg.profile == "laptop" then
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
          ]
        else if cfg.profile == "desktop" then
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
          ]
        else if cfg.profile == "workstation" then
          [
            {
              timeout = 600;
              command = "${noctaliaBin} msg session lock && ${niriBin} msg action power-off-monitors";
              resumeCommand = "${niriBin} msg action power-on-monitors";
            }
          ]
        else
          [ ];
    };
  };
}

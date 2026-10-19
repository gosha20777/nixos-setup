{ config, ... }:

{
  # Machine-specific SSH key from secrets/lab.yaml
  sops.secrets."id_ed25519" = {
    sopsFile = ../../secrets/lab.yaml;
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };

  # ── Dual 27" QHD Displays (AOC Q27P2W, 2560x1440 @ 60Hz) ──
  # Calibrated for 60 cm viewing distance (main) & 75-80 cm (aux) with 0.3 decimal acuity.
  # Optimal scale:
  #   - Main (left, 60 cm): 1.60 (logical: 1600x900, 4.90x MAR)
  #   - Aux (right, 75-80 cm): 2.25 (logical: 1138x640, 5.30x MAR)
  #
  # Outputs are matched by "PNP(AOC) Q27P2W <serial>" for rock-solid stability across GPU ports.
  programs.niri.settings = {
    outputs = {
      # Left (primary) monitor — user sits directly in front of it (HDMI-A-2)
      "PNP(AOC) Q27P2W TAIN1HA005856" = {
        mode = {
          width = 2560;
          height = 1440;
        };
        scale = 1.6;
        position = {
          x = 0;
          y = 0;
        };
        focus-at-startup = true;
      };

      # Right (auxiliary) monitor — placed adjacent to the right (x = 2560 / 1.6 = 1600)
      "PNP(AOC) Q27P2W ASEP99A002074" = {
        mode = {
          width = 2560;
          height = 1440;
        };
        scale = 2.25;
        position = {
          x = 1600;
          y = 0;
        };
      };
    };

    # Pin default workspaces to the primary (left) monitor
    workspaces = {
      "01-web".open-on-output = "PNP(AOC) Q27P2W TAIN1HA005856";
      "02-dev".open-on-output = "PNP(AOC) Q27P2W TAIN1HA005856";
      "03-game".open-on-output = "PNP(AOC) Q27P2W TAIN1HA005856";
    };
  };

  # ── Noctalia Shell Overrides ──
  # Disable top bar on the auxiliary monitor (DP-2)
  programs.noctalia.settings.bar.default.monitor.aux = {
    match = "DP-2";
    enabled = false;
  };
}

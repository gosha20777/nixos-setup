{ config, ... }:

{
  # Machine-specific SSH key from secrets/lab.yaml
  sops.secrets."id_ed25519" = {
    sopsFile = ../../secrets/lab.yaml;
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };

  # ── Dual 27" QHD Displays (AOC Q27P2W, 2560x1440 @ 60Hz) ──
  # Calibrated for 50 cm viewing distance & 0.3 decimal visual acuity per display-scaling.md.
  # Optimal scale: 1.60 (logical size: 1600x900 on each display).
  #
  # Outputs are matched by "make model serial" for rock-solid stability across GPU ports.
  programs.niri.settings = {
    outputs = {
      # Left (primary) monitor — user sits directly in front of it
      "AOC Q27P2W TAIN1HA005856" = {
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

      # Right (auxiliary) monitor — placed immediately adjacent to the right (x = 2560 / 1.6 = 1600)
      "AOC Q27P2W ASEP99A002074" = {
        mode = {
          width = 2560;
          height = 1440;
        };
        scale = 1.6;
        position = {
          x = 1600;
          y = 0;
        };
      };
    };

    # Pin default workspaces to the primary (left) monitor
    workspaces = {
      "01-web".open-on-output = "AOC Q27P2W TAIN1HA005856";
      "02-dev".open-on-output = "AOC Q27P2W TAIN1HA005856";
      "03-game".open-on-output = "AOC Q27P2W TAIN1HA005856";
    };
  };
}

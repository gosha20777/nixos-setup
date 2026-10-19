{ config, ... }:

{
  # Machine-specific SSH key from secrets/lab.yaml
  sops.secrets."id_ed25519" = {
    sopsFile = ../../secrets/lab.yaml;
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };

  # ── Dual 27" QHD Displays (AOC Q27P2W, 2560x1440 @ 75Hz) ──
  # Layout: [Auxiliary (HDMI, left)] <- [Primary (DP, right)]
  # User sits directly in front of the right monitor (DP-2).
  # Scales:
  #   - Main (right, 60 cm): 1.60 (logical: 1600x900)
  #   - Aux (left, 75-80 cm): 2.25 (logical: 1138x640)
  #
  # Outputs are matched by "PNP(AOC) Q27P2W <serial>" for rock-solid stability across GPU ports.
  programs.niri.settings = {
    outputs = {
      # Left (auxiliary) monitor — placed on the left (x = 0, HDMI-A-3)
      "PNP(AOC) Q27P2W TAIN1HA005856" = {
        mode = {
          width = 2560;
          height = 1440;
        };
        scale = 2.25;
        position = {
          x = 0;
          y = 0;
        };
      };

      # Right (primary) monitor — user sits directly in front of it (x = 2560 / 2.25 = 1138, DP-2)
      "PNP(AOC) Q27P2W ASEP99A002074" = {
        mode = {
          width = 2560;
          height = 1440;
        };
        scale = 1.6;
        position = {
          x = 1138;
          y = 0;
        };
        focus-at-startup = true;
      };
    };

    # Pin default workspaces to the primary (right) monitor
    workspaces = {
      "01-web".open-on-output = "PNP(AOC) Q27P2W ASEP99A002074";
      "02-dev".open-on-output = "PNP(AOC) Q27P2W ASEP99A002074";
      "03-game".open-on-output = "PNP(AOC) Q27P2W ASEP99A002074";
    };
  };

  # ── Noctalia Shell Overrides ──
  # Disable top bar on the auxiliary monitor (HDMI)
  programs.noctalia.settings.bar.default.monitor.aux = {
    match = "HDMI-A-3";
    enabled = false;
  };
}

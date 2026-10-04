# VueScan film and photo scanning software.
# Proprietary package with native auto-patchelf, declarative sops license, and seeded writable presets.
{
  config,
  lib,
  pkgs,
  systemSettings,
  ...
}:
let
  theme = import ../../themes/${systemSettings.theme};
  vuescan = pkgs.callPackage ../../packages/vuescan {
    gtkTheme = theme.gtkTheme or "Everforest-Dark";
  };
  dataDir = ../../data/vuescan;
in
{
  home.packages = [ vuescan ];

  # 1. SOPS license file (~/.vuescanrc)
  sops = lib.mkIf systemSettings.sops.enable {
    secrets.vuescan_license = { };

    templates."vuescanrc" = {
      path = "${config.home.homeDirectory}/.vuescanrc";
      mode = "0600";
      content = config.sops.placeholder.vuescan_license;
    };
  };

  # 2. Seed writable configuration presets (~/.vuescan/)
  # Copied once on activation if missing, preserved as plain writable files so VueScan
  # can update crop coordinates, scan counters, and calibration without Nix collisions.
  home.activation.vuescanSeed = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      DIR="$HOME/.vuescan"
      ${pkgs.coreutils}/bin/mkdir -p "$DIR"

      for preset in half-frame-bw.ini half-frame-color.ini standart-bw.ini standart-color.ini vuescan.ini; do
        if [ ! -f "$DIR/$preset" ]; then
          ${pkgs.coreutils}/bin/install -m 0644 "${dataDir}/$preset" "$DIR/$preset"
        fi
      done

      # Ensure DarkMode=1 is configured under [Prefs] in vuescan.ini
      if [ -f "$DIR/vuescan.ini" ] && ! grep -q "^DarkMode=" "$DIR/vuescan.ini"; then
        ${pkgs.gnused}/bin/sed -i '/^\[Prefs\]/a DarkMode=1' "$DIR/vuescan.ini"
      fi
    '';
  };
}

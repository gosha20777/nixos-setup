# Photo workflow tools:
# - vipsdisp: lightning-fast default image viewer (GTK4 + libvips tile streaming)
# - gThumb: photo gallery and fast organizer/editor (GTK)
# - ART: professional non-destructive RAW/TIFF processor (Another RawTherapee)
{ pkgs, ... }:
{
  home.packages = [
    pkgs.vipsdisp
    pkgs.gthumb
    pkgs.art
  ];

  # Pre-configure ART: save .arp sidecar files in cache (~/.cache/ART/) instead of next to image files
  home.activation.artConfigSeed = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
            ART_DIR="$HOME/.config/ART"
            ART_CONF="$ART_DIR/options"

            if [ -f "$ART_CONF" ]; then
              if ${pkgs.gnugrep}/bin/grep -q "^SaveParamsWithFile=" "$ART_CONF"; then
                ${pkgs.gnused}/bin/sed -i 's/^SaveParamsWithFile=.*/SaveParamsWithFile=false/' "$ART_CONF"
              else
                ${pkgs.gnused}/bin/sed -i '/^\[Profiles\]/a SaveParamsWithFile=false' "$ART_CONF" 2>/dev/null || echo "SaveParamsWithFile=false" >> "$ART_CONF"
              fi

              if ${pkgs.gnugrep}/bin/grep -q "^SaveParamsToCache=" "$ART_CONF"; then
                ${pkgs.gnused}/bin/sed -i 's/^SaveParamsToCache=.*/SaveParamsToCache=true/' "$ART_CONF"
              else
                ${pkgs.gnused}/bin/sed -i '/^\[Profiles\]/a SaveParamsToCache=true' "$ART_CONF" 2>/dev/null || echo "SaveParamsToCache=true" >> "$ART_CONF"
              fi
            else
              ${pkgs.coreutils}/bin/mkdir -p "$ART_DIR"
              ${pkgs.coreutils}/bin/cat > "$ART_CONF" <<'EOF'
      [Profiles]
      SaveParamsWithFile=false
      SaveParamsToCache=true
      EOF
            fi
    '';
  };
}

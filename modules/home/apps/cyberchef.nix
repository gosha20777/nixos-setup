# CyberChef — no nixpkgs package; pull the latest release zip
{
  pkgs,
  ...
}:
{
  home.activation.cyberchef = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      DEST="$HOME/.local/share/cyberchef"
      LAUNCHER="$HOME/.local/bin/cyberchef"
      if [ ! -x "$LAUNCHER" ] || [ ! -d "$DEST" ]; then
        TMP=$(${pkgs.coreutils}/bin/mktemp -d)
        URL=$(${pkgs.curl}/bin/curl -fsSL https://api.github.com/repos/gchq/CyberChef/releases/latest \
              | ${pkgs.gnugrep}/bin/grep -oE '"browser_download_url": *"[^"]+\.zip"' \
              | ${pkgs.coreutils}/bin/head -1 \
              | ${pkgs.gnused}/bin/sed -E 's/.*"(https[^"]+)".*/\1/')
        if [ -n "$URL" ]; then
          ${pkgs.curl}/bin/curl -fsSL -o "$TMP/cc.zip" "$URL" && {
            ${pkgs.coreutils}/bin/mkdir -p "$DEST" "$HOME/.local/bin"
            ${pkgs.unzip}/bin/unzip -q -o "$TMP/cc.zip" -d "$DEST"
            IDX=$(${pkgs.findutils}/bin/find "$DEST" -maxdepth 3 -name 'CyberChef_v*.html' -print -quit)
            [ -z "$IDX" ] && IDX=$(${pkgs.findutils}/bin/find "$DEST" -maxdepth 3 -name 'index.html' -print -quit)
            if [ -n "$IDX" ]; then
              ${pkgs.coreutils}/bin/printf '#!/usr/bin/env bash\nxdg-open "%s"\n' "$IDX" > "$LAUNCHER"
              ${pkgs.coreutils}/bin/chmod +x "$LAUNCHER"
            fi
          }
        fi
        ${pkgs.coreutils}/bin/rm -rf "$TMP"
      fi
    '';
  };
}

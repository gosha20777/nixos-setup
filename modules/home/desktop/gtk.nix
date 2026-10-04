# GTK theming. adw-gtk3 (native libadwaita port for GTK3) + graphite-cursors (vinceliuice).
# Noctalia's native design: Noctalia templates render noctalia.css with palette colors,
# which recolor adw-gtk3 and libadwaita apps dynamically via @import in gtk.css.
{
  pkgs,
  systemSettings,
  ...
}:
let
  theme = import ../../themes/${systemSettings.theme};
in
{
  gtk = {
    enable = true;
    theme = {
      name = theme.gtkTheme or "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.papirus-folders ];
        postInstall = (old.postInstall or "") + ''
          XDG_DATA_DIRS="$out/share" papirus-folders -o -C green --theme Papirus-Dark
        '';
      });
    };
    cursorTheme = {
      name = "graphite-dark";
      package = pkgs.graphite-cursors;
      size = 24;
    };
    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        gtk-decoration-layout = "appmenu:none";
      };
      extraCss = ''
        @import url("noctalia.css");
      '';
    };
    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
        gtk-decoration-layout = "appmenu:none";
      };
      extraCss = ''
        @import url("noctalia.css");
      '';
    };
  };
}

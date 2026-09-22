# GTK theming. Everforest-Dark (Fausto-Korpsvart) + graphite-cursors (vinceliuice).
# adw-gtk3 удален из пакетов, поэтому apply.sh Noctalia не переключает gsettings
# gtk-theme обратно на adw-gtk3. При этом шаблоны gtk3/gtk4 рендерят noctalia.css
# с цветами палитры, которые подмешиваются через @import в gtk.css.
{
  pkgs,
  ...
}:
{
  gtk = {
    enable = true;
    theme = {
      name = "Everforest-Dark";
      package = pkgs.everforest-gtk-theme;
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

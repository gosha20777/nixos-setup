# GTK theming. Everforest-Dark (Fausto-Korpsvart) + everforest-cursors (phinger-based).
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
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "everforest-cursors";
      package = pkgs.everforest-cursors;
      size = 24;
    };
    gtk3 = {
      extraConfig.gtk-application-prefer-dark-theme = 1;
      extraCss = ''
        @import url("noctalia.css");
      '';
    };
    gtk4 = {
      extraConfig.gtk-application-prefer-dark-theme = 1;
      extraCss = ''
        @import url("noctalia.css");
      '';
    };
  };
}

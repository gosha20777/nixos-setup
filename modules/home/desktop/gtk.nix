# GTK theming. adw-gtk3-dark is a libadwaita-style GTK3 port — it's
# exactly what Noctalia's gtk-refresh.py expects to switch to (script
# hardcodes "adw-gtk3" / "adw-gtk3-dark" as the target via gsettings).
# Noctalia's gtk3/gtk4 templates write ~/.config/gtk-{3,4}.0/noctalia.css on
# each wallpaper change; the @import in our managed gtk.css pulls those
# @define-color overrides into every GTK app without us touching gtk.css
# ourselves. enableUserTheming stays off — we use only the built-in gtk3/gtk4
# templates, enabled via programs.noctalia.settings.theme.templates
# (modules/home/desktop/noctalia.nix).
{
  pkgs,
  ...
}:
{
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
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

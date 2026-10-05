# Qt theming and desktop portal integration.
# Forces Qt applications (including Qt5 and Qt6) to use GTK platform theme
# and route file dialogs through xdg-desktop-portal-gtk instead of the legacy fallback.
{
  pkgs,
  ...
}:
{
  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style.name = "adwaita-dark";
  };

  home.sessionVariables = {
    QT_USE_PORTAL = "1";
  };
}

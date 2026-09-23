{
  config,
  lib,
  pkgs,
  ...
}:
{
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        "org.freedesktop.impl.portal.Access" = [ "gtk" ];
        "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;
  services.accounts-daemon.enable = true;
  programs.dconf.enable = true;

  # Thumbnail management service (D-Bus Thumbnailer1) for Nemo and GTK file dialogs
  services.tumbler.enable = true;

  # Background file indexing and instant search
  services.gnome.tracker.enable = true;
  services.gnome.tracker-miners.enable = true;

  # gvfs — the GNOME virtual filesystem daemon. Nemo (in
  # environment.systemPackages) degrades quietly without it: no Trash, no
  # network mounts (SMB/SFTP), no MTP for phones. Nothing errors, the
  # features are simply absent from the UI, so this is easy to miss.
  services.gvfs.enable = true;
}

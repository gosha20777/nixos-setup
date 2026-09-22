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
  };

  services.gnome.gnome-keyring.enable = true;
  services.accounts-daemon.enable = true;
  programs.dconf.enable = true;

  # gvfs — the GNOME virtual filesystem daemon. Nemo (in
  # environment.systemPackages) degrades quietly without it: no Trash, no
  # network mounts (SMB/SFTP), no MTP for phones. Nothing errors, the
  # features are simply absent from the UI, so this is easy to miss.
  services.gvfs.enable = true;
}

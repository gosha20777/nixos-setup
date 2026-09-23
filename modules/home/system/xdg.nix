# User directory structure (XDG) and file manager bookmarks/icons
{ config, ... }:
{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;

    # Standard XDG user directories
    documents = "${config.home.homeDirectory}/Documents";
    download = "${config.home.homeDirectory}/Downloads";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    music = "${config.home.homeDirectory}/Music";

    # Custom directories
    extraConfig = {
      XDG_PROJECTS_DIR = "${config.home.homeDirectory}/Projects";
      XDG_GAMES_DIR = "${config.home.homeDirectory}/Games";
    };
  };

  # Contextual directory icons for Nemo / FreeDesktop file managers
  home.file = {
    "Projects/.directory".text = ''
      [Desktop Entry]
      Icon=folder-development
      Type=Directory
    '';
    "Games/.directory".text = ''
      [Desktop Entry]
      Icon=folder-games
      Type=Directory
    '';
  };

  # GTK sidebar bookmarks for Nemo / GTK file chooser dialogs
  gtk.gtk3.bookmarks = [
    "file://${config.home.homeDirectory}/Projects Projects"
    "file://${config.home.homeDirectory}/Games Games"
    "file://${config.home.homeDirectory}/Documents Documents"
    "file://${config.home.homeDirectory}/Downloads Downloads"
    "file://${config.home.homeDirectory}/Pictures Pictures"
  ];
}

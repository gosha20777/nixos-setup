{
  config,
  lib,
  pkgs,
  ...
}:
{
  ############################################################
  # System-wide GUI applications
  ############################################################
  environment.systemPackages = with pkgs; [
    google-chrome
    vscode
    telegram-desktop
    nemo-with-extensions
    nemo-preview
    file-roller
    p7zip
    zip
    ffmpegthumbnailer
    webp-pixbuf-loader
    evince
    gnome-epub-thumbnailer
    obsidian

    typora
    git
    curl
    wget
    unzip
    cryptsetup # handy for inspecting/managing the LUKS volume post-install

  ];
}

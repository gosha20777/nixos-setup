{
  config,
  lib,
  pkgs,
  ...
}:
let
  vuescan = pkgs.callPackage ../../packages/vuescan { };
in
{
  ############################################################
  # System-wide GUI applications
  ############################################################
  environment.systemPackages = with pkgs; [
    google-chrome
    vscode
    nemo-with-extensions
    nemo-preview
    file-roller
    bulky
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

  # Udev rules for USB scanner access (VueScan)
  services.udev.packages = [ vuescan ];
}

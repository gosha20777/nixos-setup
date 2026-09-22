{ pkgs, ... }:
{
  home.packages = [
    pkgs.kdePackages.kdenlive
    pkgs.ffmpeg-full
  ];
}

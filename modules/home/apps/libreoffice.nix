{ pkgs, ... }:
{
  home.packages = [
    pkgs.libreoffice
    pkgs.hunspell
    pkgs.hunspellDicts.ru_RU
    pkgs.hunspellDicts.en_US
  ];
}

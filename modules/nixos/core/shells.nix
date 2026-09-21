{
  config,
  lib,
  pkgs,
  ...
}:
{
  ############################################################
  # Shells (Fish primary, Bash standard)
  ############################################################
  programs.bash.enable = true;
  programs.fish.enable = true;
  environment.shells = [
    pkgs.fish
    pkgs.bash
  ];
}

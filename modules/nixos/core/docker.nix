{
  config,
  lib,
  pkgs,
  ...
}:
{
  ############################################################
  # Containers
  ############################################################
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };
}

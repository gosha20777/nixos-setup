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

  # NVIDIA Container Toolkit (CDI) — enable only on hosts running the NVIDIA driver.
  # On hosts without nvidia (dev VM, live ISO), this stays false so assertions pass.
  hardware.nvidia-container-toolkit.enable = lib.elem "nvidia" config.services.xserver.videoDrivers;
}

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../common.nix
    ./disko.nix
    ../../modules/nixos/roles/desktop.nix
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
  ];

  networking.hostName = "pc";
  nixpkgs.hostPlatform = "x86_64-linux";

  # ── Kernel & Hardware ──
  boot.kernelModules = [ "it87" ];
  environment.systemPackages = [ pkgs.lm_sensors ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  hardware.enableRedistributableFirmware = true;

  # ── Graphics: Standalone NVIDIA (Turing TU102) ──
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    # Turing is fully supported by the open kernel modules
    open = true;
    nvidiaSettings = true;
    # Force the latest branch (615+) for explicit sync and robust Wayland support
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };

  # ── Apps ──
  my.apps.steam.enable = true;

  # ── Swap & Storage ──
  # Compressed RAM swap (25% total RAM ≈ 15.5 GB virtual swap)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # Cold storage HDD (Toshiba 1.8TB) for backups and archives
  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-label/storage";
    fsType = "btrfs";
  };

  # ── Backups ──
  my.services.restic.enable = true;
  sops.age.keyFile = "/home/${config.systemSettings.username}/.config/sops/age/keys.txt";
  sops.secrets."restic/password".sopsFile = ../../secrets/pc.yaml;

  home-manager.users.${config.systemSettings.username}.imports = [ ./home.nix ];
}

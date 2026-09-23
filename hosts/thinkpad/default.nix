# Host configuration for Lenovo ThinkPad P1 Gen 2
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
    ../../modules/disko/btrfs-uefi.nix
    ../../modules/nixos/roles/laptop.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p1
  ];

  networking.hostName = "thinkpad";
  nixpkgs.hostPlatform = "x86_64-linux";

  # Disko NVMe SSD target
  disko.devices.disk.main.device = "/dev/nvme0n1";

  # Compressed RAM swap (25% total RAM ≈ 8 GB virtual swap, ~2.5 GB real RAM)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # Intel CPU microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  # Hardware quirks & deep power saving
  boot = {
    # Fix ACPI battery reporting glitch on boot (ArchWiki)
    initrd.availableKernelModules = [ "battery" ];

    # Force PCIe Active State Power Management into L1 low-power states
    kernelParams = [ "pcie_aspm=force" ];

    # Audio & Wi-Fi aggressive idle power saving
    extraModprobeConfig = ''
      options snd_hda_intel power_save=1 power_save_controller=Y
      options iwlwifi power_save=1 uapsd_disable=0
    '';
  };

  # ── Graphics: Hybrid Intel UHD 630 + NVIDIA Quadro T1000 ──
  # Proprietary driver supplies nvidia-smi and kernel RTD3 power management
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    # Enable experimental systemd and PCIe Runtime D3 (RTD3 / D3Cold)
    # The Quadro T1000 (Turing TU117) powers down completely (0W) when idle
    powerManagement = {
      enable = true;
      finegrained = true;
    };

    # Closed source driver is required for stable RTD3 on Turing mobile GPUs
    open = false;
    nvidiaSettings = true;

    # PRIME Render Offload: Intel renders Wayland/niri, NVIDIA offloads on request
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # provides `nvidia-offload` wrapper
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ── CPU Power Management: Lenovo Throttling Fix & Battery Limits ──
  services.throttled = {
    enable = true;
    extraConfig = ''
      [BATTERY]
      # Cap long-term power limit (PL1) to 20W and short-term (PL2) to 30W on battery
      PL1_Tdp_W = 20
      PL2_Tdp_W = 30
      Trip_Temp_C = 80
    '';
  };

  # Automatically switch power-profiles-daemon on AC/battery events
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
  '';

  # Per-host home overrides
  home-manager.users.${config.systemSettings.username}.imports = [ ./home.nix ];
}

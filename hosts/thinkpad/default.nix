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
      [GENERAL]
      Enabled: True
      Sysfs_Power_Path: /sys/class/power_supply/AC*/online
      Autoreload: True

      [BATTERY]
      Update_Rate_s: 30
      PL1_Tdp_W: 16
      PL1_Duration_s: 28
      PL2_Tdp_W: 22
      PL2_Duration_S: 0.002
      Trip_Temp_C: 75
      cTDP: 1

      [AC]
      Update_Rate_s: 5
      PL1_Tdp_W: 28
      PL1_Duration_s: 28
      PL2_Tdp_W: 35
      PL2_Duration_S: 0.002
      Trip_Temp_C: 87
      cTDP: 0
    '';
  };

  # ── Fan Control: Ультра-плавный профиль (0 RPM до 60°C, возврат в BIOS на 90°C) ──
  services.thinkfan = {
    enable = true;
    levels = [
      [
        0
        0
        60
      ]
      [
        1
        53
        65
      ]
      [
        2
        59
        70
      ]
      [
        3
        64
        75
      ]
      [
        4
        69
        80
      ]
      [
        5
        74
        84
      ]
      [
        6
        78
        87
      ]
      [
        7
        82
        90
      ]
      [
        "level auto"
        85
        32767
      ]
    ];
  };

  # Automatically switch power-profiles-daemon on AC/battery events
  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
    SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
  '';

  # Per-host home overrides
  home-manager.users.${config.systemSettings.username}.imports = [ ./home.nix ];
}

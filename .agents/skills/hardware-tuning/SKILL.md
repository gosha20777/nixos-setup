---
name: hardware-tuning
description: Rigorous hardware inspection, power management optimization, and hardware enablement for NixOS laptops and workstations. Mandates deep research (NixOS Wiki -> ArchWiki -> Nixpkgs source inspection), zero custom scripts (native drivers and standard daemons only), permission boundary checks, and a strict user approval workflow.
---

# Hardware Tuning & Enablement Skill

Use this skill whenever enabling new hardware, optimizing battery life/power consumption, configuring hybrid GPUs (Intel/NVIDIA/AMD), fixing vendor-specific thermal/fan quirks, or diagnosing peripherals (touchpad, audio, Wi-Fi, sensors) in this repository.

---

## 1. Core Principles

1. **Native Mechanisms Only (Zero Custom Scripts):**
   - Strictly avoid homebrew background scripts, ad-hoc polling loops, or custom shell daemons for hardware management.
   - Rely exclusively on native Linux kernel drivers, hardware registers (Intel Speed Shift / HWP, AMD P-State, PCIe ASPM), standard system daemons (`power-profiles-daemon`, `throttled`, `upower`), and official NixOS modules (`nixos-hardware`, `hardware.nvidia`).

2. **Source Code Inspection Before Adoption:**
   - If considering an unfamiliar Nixpkgs package or module (e.g. `throttled`, `bumblebee`, `zcfan`), do not trust marketing descriptions. Inspect its Nix derivation and configuration file in Nixpkgs or GitHub to verify exactly what systemd units, MSR registers, or kernel flags it touches.

3. **Permission & Execution Boundaries:**
   - If a diagnostic command requires elevated root privileges (`sudo`, hardware register writes, flashing firmware) or is blocked by the environment, **STOP immediately**. Ask the user to execute the command on their terminal and provide the output. Never guess hardware responses.

---

## 2. Mandatory 6-Stage Hardware Engineering Workflow

Any AI model or engineer performing hardware tuning MUST execute these six stages sequentially:

### Stage 1: Live Hardware Discovery
Before proposing any code, discover the physical reality of the machine using non-destructive inspection:
- **CPU & Architecture:** Model, core/thread count, scaling driver (`/sys/devices/system/cpu/cpu0/cpufreq/scaling_driver`), current/min/max frequencies, available EPP preferences.
- **GPU & Video Topology:** Inspect all DRM cards (`/sys/class/drm/card*-*`). Determine exactly which card (integrated vs discrete) physically drives internal displays (`eDP-1`) and external ports (`HDMI-A-1`, `DP-1`).
- **Storage & Block Devices:** NVMe vs SATA (`lsblk -d -o NAME,SIZE,MODEL,TRAN`), vendor features, APST/TRIM capabilities.
- **Power & ACPI:** Battery status, ACPI platform profile choices (`/sys/firmware/acpi/platform_profile_choices`), thermal trip points.

### Stage 2: Authoritative Research Protocol
Conduct research strictly in this order:
1. **NixOS Official Wiki & Manual:** Search for existing NixOS options and community recommendations (e.g. `services.xserver.videoDrivers = [ "nvidia" ]`, `hardware.nvidia.powerManagement.finegrained`).
2. **ArchWiki Hardware Database:** Search for the exact laptop/board model and its hardware twin (e.g. ThinkPad P1 Gen 2 / X1 Extreme Gen 2). Look for:
   - Video routing quirks (eDP wired to Intel, HDMI to NVIDIA).
   - Known kernel bugs (e.g. battery statistics reporting, trackpoint communication protocols, suspend freezes).
   - Specific kernel parameters (`pcie_aspm=force`, `snd_hda_intel power_save=1`).
3. **Nixpkgs & `nixos-hardware` Search:** Check if an official profile exists in `inputs.nixos-hardware.nixosModules.<model>` to reuse battle-tested community fixes.

### Stage 3: Deep Source Code Inspection
Before adding any package or module:
- Inspect its Nix expression in Nixpkgs:
  ```bash
  # Check module implementation in nixpkgs:
  nix eval --raw nixpkgs#<package>.meta.description
  ```
- Understand its default configuration and ensure it does not conflict with existing services (e.g. `power-profiles-daemon` vs `tlp` vs `auto-cpufreq`).

### Stage 4: Clarification & Proactive Questions
- Do not make assumptions about user tradeoffs (e.g. absolute maximum battery life vs burst compilation performance).
- Ask concrete, specific questions with 2–3 clear options.
- If root diagnostic output is needed (e.g. `sudo dmesg | grep -i nvme`), ask the user directly.

### Stage 5: Proposal & Plan Formulation
- Summarize findings: exact hardware specs discovered, findings from ArchWiki/NixOS docs, and trade-offs.
- Present a concrete configuration proposal specifying:
  - Exact target file (`hosts/<name>/default.nix` or `hosts/<name>/home.nix`).
  - Native Nix options to enable.
  - Verification steps.

### Stage 6: Approval Gate & Execution
- **CRITICAL:** Do NOT modify any Nix code until the user explicitly reviews and approves the proposal.
- Apply the changes cleanly.
- Verify evaluation using `nix eval --raw "path:.#nixosConfigurations.<host>.config.system.build.toplevel.drvPath"`.
- **Zero Auto-Commits:** Never create a Git commit unless explicitly instructed by the user.

---

## 3. Reference Patterns for Hybrid Laptops (Intel + NVIDIA)

### NVIDIA Turing / Ampere Dynamic Power Off (RTD3)
For modern hybrid laptops with discrete NVIDIA GPUs:
```nix
services.xserver.videoDrivers = [ "nvidia" ];

hardware.nvidia = {
  modesetting.enable = true;
  powerManagement = {
    enable = true;
    finegrained = true; # Powers down GPU to D3Cold (0W) when not rendering
  };
  open = false; # Proprietary driver is required for stable RTD3 on Turing mobile
  prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true; # Provides `nvidia-offload`
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };
};
```

### Native CPU Power Management & Thermal Control
```nix
# Native power profile daemon (tied to hardware EPP and Lenovo ACPI platform_profile)
services.power-profiles-daemon.enable = true;

# Automatic AC/Battery switching without custom scripts
services.udev.extraRules = ''
  SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
  SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
'';

# Thermal limit tuning on battery
services.throttled = {
  enable = true;
  extraConfig = ''
    [BATTERY]
    PL1_Tdp_W = 20
    PL2_Tdp_W = 30
    Trip_Temp_C = 80
  '';
};
```

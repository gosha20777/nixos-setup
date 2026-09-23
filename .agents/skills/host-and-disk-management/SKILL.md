---
name: host-and-disk-management
description: Manage NixOS host configurations, declarative disk partitioning via Disko (Btrfs subvolumes, UEFI/BIOS boot), hardware roles, and multi-architecture targets (x86_64, aarch64). Enforces strict agent workflow (read -> ask -> plan -> approval -> execute).
---

# Host & Disk Management Skill (Disko, Multi-Arch, Btrfs)

Use this skill whenever adding a new machine, modifying disk layouts, updating boot configurations, or tweaking hardware profiles across the fleet.

---

## 1. Architecture Overview

### A. Multi-Host Directory Layout
Every physical or virtual machine lives under `hosts/<hostname>/`:
* **`hosts/<hostname>/default.nix`**: System-level configuration. Imports `../common.nix`, the appropriate Disko layout, hardware roles, and declares `networking.hostName`.
* **`hosts/<hostname>/home.nix`**: User-level overrides. Attached in `default.nix` via `home-manager.users.${config.systemSettings.username}.imports = [ ./home.nix ];`. Holds monitor modes, scales, and session agents.
* **Auto-Discovery:** `flake.nix` automatically iterates over every directory in `./hosts` and exposes it as `nixosConfigurations.<dirname>`. Adding a host never requires editing `flake.nix`.

### B. Strict Multi-Architecture Principle
This repository targets both **`x86_64-linux`** (ThinkPad, Dev VM, desktops) and future **`aarch64-linux`** (ARM laptops, Apple Silicon Asahi, Raspberry Pi):
* **RULE:** `nixpkgs.hostPlatform` MUST be declared **strictly inside `hosts/<hostname>/default.nix`**.
* **RULE:** Shared modules (`modules/nixos/core/*`, `modules/home/*`) MUST remain completely architecture-neutral. Never hardcode platform strings in shared code.

### C. Declarative Disk Layouts (Disko: "Shared Templates + Local Overrides")
All disk partitioning is managed declaratively via **`disko`**, completely eliminating manually generated `hardware-configuration.nix` files with rigid UUIDs:

1. **Standard Single-Disk UEFI (`modules/disko/btrfs-uefi.nix`):**
   - Partition 1: ESP (1 GiB, type `EF00`, format `vfat`, mountpoint `/boot`, `umask=0077`). Directly boots `systemd-boot`.
   - Partition 2: Btrfs (100% remaining space) with Timeshift-compatible subvolumes:
     - `@` $\to$ `/` (`compress=zstd:3,noatime,discard=async,space_cache=v2`)
     - `@home` $\to$ `/home`
     - `@nix` $\to$ `/nix` (isolated from system snapshots to prevent disk exhaustion)
     - `@log` $\to$ `/var/log` (logs preserved across root rollbacks)
     - `@snapshots` $\to$ `/.snapshots`
   - Default device: `disko.devices.disk.main.device = lib.mkDefault "/dev/nvme0n1";`.

2. **Standard Single-Disk BIOS (`modules/disko/btrfs-bios.nix`):**
   - For virtual machines (QEMU/Gnome Boxes) or legacy hardware.
   - Partition 1: `boot` (1 MiB, type `EF02`, priority 1 for GRUB on GPT).
   - Partition 2: Btrfs with identical subvolumes.
   - Default device: `disko.devices.disk.main.device = lib.mkDefault "/dev/sda";`.

3. **Complex / Multi-Disk Machines (2+ Disks, RAID, Separate /home):**
   - **DO NOT** import shared templates from `modules/disko/`.
   - Instead, create an isolated `hosts/<hostname>/disko.nix` file defining `disko.devices.disk.<disk1>` and `disk.<disk2>` from scratch. This guarantees that complex setups never break standard machines.

### D. Memory & Swap Policy
* Use **`zramSwap`** in RAM for all machines:
  ```nix
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25; # 8 GB virtual swap on a 32 GB machine, ~2.5 GB real RAM
  };
  ```
* **No disk swap:** Do not create swap partitions or Btrfs swapfiles on NVMe SSDs unless the user explicitly requests hibernation (suspend-to-disk). Pure `zramSwap` delivers 0 byte SSD write wear and maximum memory speed.

---

## 2. Mandatory Protocol for AI Models / Agents

Any agent adding or updating a host configuration MUST follow this strict 5-stage protocol:

### Stage 1: Read and Inspect
- Inspect target machine hardware (CPU vendor/arch, GPU setup, disk device paths, UEFI vs BIOS).
- Read `hosts/common.nix` to understand the base imports.
- Read existing reference hosts (`hosts/thinkpad/` for UEFI/laptop, `hosts/dev/` for BIOS/VM).
- Read the intended Disko template (`modules/disko/btrfs-uefi.nix` or `btrfs-bios.nix`).

### Stage 2: Clarification (Ask User)
- If the target disk (`/dev/nvme0n1` vs `/dev/sda`), architecture (`x86_64` vs `aarch64`), or display scaling factor is unknown or ambiguous, ask the user before writing files.

### Stage 3: Write Detailed Plan
- Specify exact paths to be created: `hosts/<name>/default.nix`, `hosts/<name>/home.nix`.
- Specify which role to import (`modules/nixos/roles/laptop.nix` or `desktop.nix`).
- Specify the Disko template and the exact `device` override.
- Specify verification steps.

### Stage 4: User Approval Gate
- **NEVER create or modify host directories until the user explicitly approves the plan.**

### Stage 5: Execution, Verification & Zero Auto-Commits
- Write the files cleanly.
- **Verification:** Run `nix eval --raw "path:.#nixosConfigurations.<hostname>.config.system.build.toplevel.drvPath"` to guarantee that the system closure evaluates with zero assertion errors and all filesystems are resolved.
- **NEVER commit automatically:** Git commits are performed ONLY upon explicit user command.

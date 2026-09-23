# hosts/

One directory per machine. Each holds everything that is specific to *that*
physical computer; the shared module trees under `modules/` (auto-imported by
`hosts/common.nix`) are host-agnostic and applied to every host here.

```
hosts/
  common.nix                 # shared wiring: import-trees modules/nixos/core,
                             #   home-manager sharedModules = modules/home, systemSettings
  dev/
    default.nix              # VM host: Legacy BIOS/GRUB, virgl Mesa 3.3, Spice
    home.nix                 # per-host user overrides (SPICE vdagent, outputs)
    hardware-configuration.nix # legacy VM filesystem layout
  thinkpad/
    default.nix              # ThinkPad P1 Gen 2: UEFI, Disko, PRIME, laptop role
    home.nix                 # per-host user overrides (eDP-1 scale, input tweaks)
```

`flake.nix` **auto-discovers** these: every directory under `hosts/` becomes
`nixosConfigurations.<dirname>`. Adding a machine means adding a directory —
you never edit `flake.nix`. (`common.nix` is a file and doesn't match the
directory filter.)

## Multi-Architecture & Host Platform

Architecture is declared **strictly per-host** to maintain multi-arch cleanliness:
- `hosts/dev/default.nix`: `nixpkgs.hostPlatform = "x86_64-linux";`
- `hosts/thinkpad/default.nix`: `nixpkgs.hostPlatform = "x86_64-linux";`
- Future ARM host: `nixpkgs.hostPlatform = "aarch64-linux";`

The shared modules under `modules/` remain completely architecture-neutral.

## Declarative Disks via Disko

Rather than relying on manually generated `hardware-configuration.nix` files,
physical hosts declare their partitioning and filesystem layouts via **Disko**
(e.g. `modules/disko/btrfs.nix`):
- Declarative subvolumes (`@`, `@home`, `@nix`, `@log`, `@snapshots`).
- Automatic ESP formatting and mounting at `/boot`.
- Dynamic `zramSwap` in RAM (no disk wear).

## What goes in `hosts/<name>/` vs the shared modules

| Belongs in `hosts/<name>/` | Belongs in `modules/` |
|---|---|
| `nixpkgs.hostPlatform` (x86_64-linux, aarch64-linux) | Everything auto-imported: `modules/nixos/core/*`, `modules/home/*` |
| Disko disk configuration import | Bootloader defaults, services, system packages, user base |
| `networking.hostName` | Hardware-class roles (`modules/nixos/roles/{laptop,desktop}.nix`) |
| The `nixos-hardware` module for the exact model | Shell, Wayland/niri, themes, desktop apps |
| Bootloader overrides (e.g. dev VM forces GRUB/BIOS) | Dev tools, CLI utilities, AI agents |
| `home.nix` — user-level overrides (monitor modes, scaling) | |
| `systemSettings.*` overrides (terminal, git identity) | |

## Adding a new host

1. **Create the host directory:**
   ```bash
   mkdir -p hosts/<hostname>
   ```

2. **Add `hosts/<hostname>/default.nix`:**
   - Import `../common.nix`.
   - Import the desired role (`modules/nixos/roles/laptop.nix` or `desktop.nix`).
   - Import the Disko partition scheme (`../../modules/disko/btrfs.nix`).
   - Set `networking.hostName = "<hostname>";`.
   - Set `nixpkgs.hostPlatform = "<architecture>";` (`x86_64-linux` or `aarch64-linux`).
   - Attach `./home.nix` via `home-manager.users.${config.systemSettings.username}.imports = [ ./home.nix ];`.

3. **Add `hosts/<hostname>/home.nix`:**
   - Configure display outputs, scales, and any per-machine dotfile overrides.

4. **Stage and build:**
   ```bash
   git add hosts/<hostname>
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

5. **Commit and push:**
   ```bash
   git commit -m "hosts: add <hostname>"
   git push
   ```

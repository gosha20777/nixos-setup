# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A personal NixOS flake managing every machine the owner runs. It is the **source of truth** for each system — the running machine is a function of these files. The layout is multi-host: each machine is a directory under `hosts/`, and `flake.nix` discovers them automatically.

The current host is `dev`, a Gnome Boxes / QEMU x86_64 VM running niri + Noctalia (Quickshell) — the test bench for config changes before they reach real machines. Shared configuration lives in small modules under `modules/` (one program per file, auto-imported via `import-tree`); hardware-class specifics live in opt-in `modules/nixos/roles/`; per-host differences in `hosts/<name>/`. A future workstation or ThinkPad slots in as a new `hosts/<name>/` without touching shared files.

The repo is built to be cloned onto a fresh machine from the NixOS live ISO and installed against. Each host's `hardware-configuration.nix` (generated per-machine by `nixos-generate-config`) is **committed** under `hosts/<hostname>/` — flakes only evaluate git-tracked files, and the disk UUIDs it carries are identifiers, not secrets. To stand up a new machine, run `scripts/new-host.sh` on it; see `hosts/README.md`.

## Commands

All builds go through the flake. Substitute `<host>` for the directory name under `hosts/` (currently `dev` — `nix flake show` lists every host the flake exposes).

```bash
# Rebuild and switch (the default verb after any edit)
sudo nixos-rebuild switch --flake .#<host>

# Test a change without making it the default boot generation
sudo nixos-rebuild test --flake .#<host>

# Build only, don't activate
sudo nixos-rebuild build --flake .#<host>

# Bump nixpkgs / niri / noctalia / claude-code-nix
nix flake update
# Or one input at a time (Nix 2.19+ positional arg; `--update-input` is deprecated)
nix flake update noctalia

# Roll back the last activation (pair with `git revert` to keep repo + system aligned)
sudo nixos-rebuild --rollback switch

# Check the flake evaluates and outputs are well-formed
nix flake check
```

There are no tests — a NixOS config is verified by evaluating and rebuilding it, not by a suite. CI runs three gates on every PR and push to `main` (see `.github/workflows/check.yml`): `nix flake check --no-build`, `nix fmt --check` over every `.nix` file, and an eval of every discovered host's system closure. No stubbing is needed — each host's `hardware-configuration.nix` is committed, so the flake evaluates in CI as-is (device paths are just strings; evaluation never touches disks).

Formatting **is** enforced: nixfmt is the linter, the tree is already clean, and CI fails on any drift. Run `nix fmt` after editing a `.nix` file — it is a no-op unless you actually introduced drift, so it will not produce a churn diff.

## Architecture

Modular structure — shared module trees under `modules/` (auto-imported), per-machine state under `hosts/`:

- **`flake.nix`** — Inputs (nixpkgs unstable, home-manager, nixos-hardware, import-tree, niri-flake, noctalia, noctalia-greeter, oh-my-pi, herdr) and the `nixosConfigurations` output. It does **not** hardcode a host: `mkHost` builds each machine from just its `hosts/<name>/` directory, and `builtins.readDir ./hosts` auto-discovers every host directory (adding a machine never touches `flake.nix`). Inputs `follows = "nixpkgs"` to keep one nixpkgs in the closure, **with one deliberate exception: `niri`** — following it is currently fatal (niri-flake asks for `libdisplay-info_0_2`, removed from nixpkgs); see the comment on that input.
- **`hosts/common.nix`** — Shared wiring every host imports: `modules/core/settings.nix` (the `systemSettings` option layer), the auto-imported `modules/nixos/core` tree (`inputs.import-tree`), the niri / noctalia-greeter / home-manager NixOS modules, and the home-manager scaffolding (`sharedModules = import-tree modules/home`, `extraSpecialArgs` carrying `inputs` + `systemSettings`).
- **`modules/core/settings.nix`** — `options.systemSettings` (username, git identity, terminal, terminalAlt) with defaults; a host overrides any of them with a plain value. Consumed by NixOS modules via `config.systemSettings` and by every HM module via the `systemSettings` module argument.
- **`modules/nixos/core/`** — Shared system modules, one feature per file (nix, boot, user, locale, network, audio, backup, docker, nix-ld, niri, greeter, portals, shells, fonts, apps). **Auto-imported** on every host: a new file here is a new feature, no import-list edit. Paths containing `/_` are ignored by import-tree (opt-out convention).
- **`modules/nixos/roles/`** — Hardware-class modules (`laptop.nix`, `desktop.nix`), **not** auto-imported; a host lists the role it wants in its `imports`. The dev VM uses neither.
- **`modules/home/`** — Shared home-manager modules, one program per file, grouped into `shells/ terminal/ cli/ dev/ desktop/ system/ agents/ apps/`. **Auto-imported** for the user via home-manager `sharedModules`. A program's package, config, and its `home.activation` hooks live together in one file.
- **`modules/packages/` / `modules/data/` / `assets/`** — custom derivations (qq), static config texts (starship base toml, Typora theme css), and binary assets (wallpapers, skills) respectively.
- **`hosts/<hostname>/`** — Everything machine-specific. `default.nix` imports `../common.nix` + `./hardware-configuration.nix`, sets `networking.hostName`, bootloader/system overrides (the dev VM forces GRUB/BIOS), and attaches `./home.nix` via `home-manager.users.<username>.imports`. `home.nix` carries per-host user overrides (VM: spice-vdagent session agent, Virtual-1 output mode). `hardware-configuration.nix` (committed) encodes filesystems and UUIDs. The only host today is `hosts/dev/`.

### Disk layout — two supported paths

**Default (Calamares install):** ESP + LUKS-encrypted ext4 root. If the user picked "Swap with Hibernate" in Calamares, a hibernation-sized swap partition is also created and listed in `hardware-configuration.nix`'s `swapDevices`. The hibernation swap unlock + `boot.resumeDevice` live in the host module (`hosts/<hostname>/default.nix`) — they're per-disk LUKS UUIDs. No LVM in this layout.

**Appendix (manual LVM-on-LUKS):**

```
nvme0n1p1  ESP (FAT32, unencrypted)
nvme0n1p2  LUKS2 → LVM "vg"
             vg/swap  92 GiB  (encrypted, holds hibernation image)
             vg/root  rest    (encrypted, ext4)
```

This path is for users who specifically want the LVM layout (multi-volume management, easier resize). It requires setting `boot.resumeDevice = "/dev/vg/swap"` in the host module (`hosts/<hostname>/default.nix`) before the install, instead of the by-UUID swap unlock the Calamares path uses. The path is a stable LVM device, independent of `hardware-configuration.nix`. Hibernation needs persistent-key encrypted swap ≥ RAM, which is why swap lives *inside* LUKS rather than as a random-key swap partition.

The Calamares teardown lines in `modules/nixos/core/niri.nix` (`services.xserver.enable = false`, `services.displayManager.gdm.enable = false`, `services.desktopManager.gnome.enable = false`) are harmless on the manual path — they're disabling things that were never installed.

### niri + Noctalia wiring

Noctalia is on the **v5** line (`flake.nix` pins the `v5.0.0-beta2` tag). v5 renamed the home-manager module from `programs.noctalia-shell` to `programs.noctalia`, replaced the `noctalia-shell ipc call <target> <fn>` surface with `noctalia msg <command…>`, and moved config from a hand-seeded `settings.json` to a declarative `config.toml`. Assume any v4-shaped snippet you find elsewhere is stale.

System side enables `programs.niri` and `programs.noctalia-greeter` — a Quickshell greeter that mirrors Noctalia Shell's palette, whose own NixOS module sets `services.greetd` with `mkDefault` (so there is no explicit greetd block here). User side imports `inputs.noctalia.homeModules.default` and enables `programs.noctalia`, with `programs.noctalia.systemd.enable = true` so the shell runs as a **systemd user unit** tied to `wayland.systemd.target` — *not* a niri `spawn-at-startup`. That is deliberate: `nixos-rebuild switch` doesn't kill a compositor-spawned shell, which used to leave a stale store-path bar alive and produce duplicate bars. The polkit agent is Noctalia's own native one (`programs.noctalia.settings.shell.polkit_agent = true`); niri-flake's bundled `polkit-kde-agent` is force-disabled in `modules/nixos/core/niri.nix` (`systemd.user.services.niri-flake-polkit.enable = lib.mkForce false`) so the two don't race on the PolicyKit1 bus name.

The lock screen is Noctalia's own (its own PAM context, raised via `WlSessionLock`). **Noctalia does not subscribe to logind's `Lock` signal**, so `loginctl lock-session` is a no-op — locking must go through `noctalia msg session lock`, which is what the `Super+Alt+L` bind and swayidle's `before-sleep` use. Media/brightness keybinds in `modules/home/desktop/niri.nix` still go through `wpctl`, `playerctl`, and `brightnessctl` (shell-agnostic).

Idle is driven by **Noctalia's own idle manager**, declared in `programs.noctalia.settings.idle.behavior` in `modules/home/desktop/noctalia.nix`: a named `lock` behavior at `timeout = 600` (10 min) running the internal `noctalia:session lock` action. It suspends to RAM and hibernates `HibernateDelaySec` later (3h, set in `modules/nixos/roles/laptop.nix` — only on hosts that import the laptop role). **swayidle** (`modules/home/desktop/swayidle.nix`) is kept for one job only: its `before-sleep` hook locks (via `noctalia msg session lock`, resolved by absolute store path because the unit's PATH is minimal) ahead of a sleep Noctalia didn't initiate — i.e. a lid close — since Noctalia has no lock-on-external-suspend hook.

### Power (Framework 13 / Ryzen 7040)

`power-profiles-daemon` is enabled in `modules/nixos/roles/laptop.nix` (opt-in, not shared); `tlp` is **explicitly disabled** there. This is Framework's recommendation for Ryzen 7040 — TLP misbehaves on this platform. Don't swap them without a reason on a Framework host. The dev VM imports neither role.

## Editing patterns

- **Adding a system-wide package**: append to `environment.systemPackages` in `modules/nixos/core/apps.nix`.
- **Adding a user CLI tool / program config**: new file `modules/home/<category>/<tool>.nix` with its `home.packages` / `programs.*` (and any activation hooks). It is auto-imported — no list to edit. `git add` it before building (flakes only see tracked files). Prefer user files over system packages unless the tool needs to be on PATH for other users or services.
- **Adding a shared system feature**: new file in `modules/nixos/core/`. Opt-out of a shared feature on one host: `lib.mkForce false` in that host's `default.nix`.
- **Per-host overrides (system)**: `hosts/<name>/default.nix` — plain value beats the shared default; `systemSettings.*` for the knob-style settings (username, terminal, git identity).
- **Per-host overrides (user)**: `hosts/<name>/home.nix` — e.g. `programs.noctalia.settings.shell.bar.position`, niri output modes/scales.
- **Adding an imperative install step** (something not in nixpkgs): `home.activation.<name>` in the program's own file under `modules/home/`, following the `apps/cyberchef.nix` / `dev/neovim.nix` patterns — guard with an existence check so reruns are idempotent.
- **Custom package** (not in nixpkgs): derivation file in `modules/packages/`, referenced via `pkgs.callPackage` from the program's home file.
- **Bumping niri or Noctalia independently of nixpkgs**: `nix flake update niri` (or `noctalia`). The `--update-input` form on `nix flake lock` is deprecated since Nix 2.19.
- **Adding a new host**: run `scripts/new-host.sh` on the target machine (see `hosts/README.md`). It scaffolds `hosts/<name>/` (default.nix + home.nix + hardware-configuration.nix) and the flake auto-discovers it — no `flake.nix` edit.
- **`allowUnfree` is on** (`nixpkgs.config.allowUnfree = true`) for `lmstudio`, `typora`, `1password`. Unfree additions are fine.

## Secure Boot

Lanzaboote is a deliberate **post-install** step, not part of the initial build. The `lanzaboote` flake input (in `flake.nix`), its module line in `hosts/common.nix`, and the `boot.lanzaboote` block in `modules/nixos/core/boot.nix` are all commented out. Enabling them before keys are enrolled in the firmware will brick the boot. The full runbook is in `secure-boot.md`; touch those commented blocks only when following it.

The lanzaboote block uses `lib.mkForce` to override systemd-boot; `lib` is already in `modules/nixos/core/boot.nix`'s function arguments, so no signature change is needed.

## What's *not* declarative (by design)

Listed in `home.activation.todoMd` (the generated `~/TODO.md`): authenticating Claude Code / Gemini CLI / `fizzy setup`, signing into 1Password / Gmail / GitHub / Slack / Discord / Signal / Zoom, joining Tailscale, setting wallpaper in Noctalia (its Material You-style theme derives from the wallpaper), syncing noctalia-greeter to the shell palette, Obsidian Sync, Typora license, Chromium extensions, `sudo fwupdmgr update`. These are credentials, account state, and firmware updates — not something Nix should own.

Ollama models are **not** on that list: `services.ollama.loadModels` (when re-added) pulls them declaratively on first start via `ollama-model-loader.service`.

## Reference docs in this repo

- **`INSTALL.md`** — Single canonical install runbook for the dev VM (Gnome Boxes / QEMU on the Fedora host): download ISO → Calamares "Erase disk" → clone the repo into `~/Projects/my_projects/nixos-setup` → `nixos-rebuild switch --flake .#dev`. Includes the QEMU/virgl setup notes (Legacy BIOS + GRUB, egl-headless display for NVIDIA hosts) and post-install verification.
- **`hosts/README.md`** — The per-host layout and the runbook for standing up a new machine with `scripts/new-host.sh` (deterministic config across different hardware).
- **`secure-boot.md`** — lanzaboote enrollment runbook (hardware-agnostic for the `sbctl` steps; Framework-specific BIOS quirks flagged inline), including optional TPM2 LUKS auto-unlock and recovery from a bricked boot.
- **`backup.md`** — Backup runbook for the restic-to-USB-drive setup configured in `modules/nixos/core/backup.nix`: running a backup on demand, verifying one landed, browsing snapshots as directories (`restic mount`), restoring a single file or the whole home, preparing a replacement drive, and troubleshooting. Note the two things Nix does not own here — a labelled physical drive and the password at `/etc/restic/home-password`, which is the only key to the repo.
- **`CONTRIBUTING.md`** — Branch/PR workflow and the per-merge checks. Every change goes through a feature branch and a PR; the repo blocks squash and rebase merges, so use `gh pr merge --merge`.

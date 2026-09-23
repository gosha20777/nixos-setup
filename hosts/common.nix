# Shared wiring for every host. Each hosts/<name>/default.nix imports this
# file; it pulls in the auto-imported module trees and the home-manager
# scaffolding, so a host's own directory stays machine-specific only.
{ inputs, config, ... }:
{
  imports = [
    # systemSettings — the single place hosts override deployment defaults
    # (username, terminal, git identity, …). Consumed by NixOS modules via
    # config.systemSettings and by every home-manager module via
    # extraSpecialArgs below.
    ../modules/core/settings.nix

    # Shared system modules — 1 feature per file, auto-imported by
    # import-tree. A new .nix file in the tree is picked up on the next
    # eval; paths containing "/_" are ignored (opt-out convention).
    (inputs.import-tree ../modules/nixos/core)

    inputs.niri.nixosModules.niri
    inputs.noctalia-greeter.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.disko.nixosModules.disko

    # ── SECURE BOOT ──
    # Uncomment together with the input in flake.nix and the block in
    # modules/nixos/core/boot.nix:
    # inputs.lanzaboote.nixosModules.lanzaboote
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
      systemSettings = config.systemSettings;
    };
    # Shared home modules — 1 program per file, auto-imported by
    # import-tree for every user. The user base (home.username,
    # stateVersion, …) is declared in modules/nixos/core/user.nix.
    sharedModules = [
      (inputs.import-tree ../modules/home)
      inputs.sops-nix.homeManagerModules.sops
    ];
  };
}

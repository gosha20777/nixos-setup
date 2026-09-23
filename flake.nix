{
  description = "NixOS + niri + Noctalia configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # import-tree — auto-import every .nix module under modules/nixos/core
    # and modules/home (hosts/common.nix wires the trees). A new file in the
    # tree is a new feature; no flake or import-list edits. Deps-free
    # callable flake; paths containing "/_" are ignored by default.
    import-tree.url = "github:denful/import-tree";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    niri = {
      url = "github:sodiboo/niri-flake";
      # DELIBERATELY no `inputs.nixpkgs.follows = "nixpkgs"`, unlike every
      # other input here. Two reasons, in order of weight:
      #
      # 1. Upstream guidance. Noctalia's own NixOS docs
      #    (docs.noctalia.dev/noctalia/getting-started/nixos) describe the
      #    follows line as optional — "prevents downloading two versions of
      #    nixpkgs but disables cache". So following is the thing that costs
      #    you the binary cache; not following is the expected default.
      #
      # 2. It is currently load-bearing. niri-flake asks for
      #    `libdisplay-info_0_2`, which nixpkgs has removed (the attr is now a
      #    throw stub pointing at _0_3). Forcing niri onto our nixpkgs makes
      #    evaluation fail outright on programs.niri.package. Upstream
      #    niri-flake hasn't moved since 2026-08-04 — its main HEAD is the
      #    commit we pin — so there is nothing to bump to. Its own pin
      #    predates the removal, so letting it use that is what unblocks
      #    nixpkgs updates.
      #
      # Cost: a second nixpkgs in the closure; niri links a different
      # mesa/wayland than the rest of the system. Accepted, and it buys cache
      # hits for niri instead of source builds.
      #
      # Note we can't simply drop niri-flake for nixpkgs' `niri`: nixpkgs ships
      # the package (26.04, older than the unstable build we run) but NO
      # programs.niri module, and modules/home/desktop/niri.nix's
      # binds/outputs/touchpad are all written as `programs.niri.settings`
      # with build-time validation.
    };

    noctalia = {
      # Pinned to the v5.0.0 beta tag (major bump from the v4 line). Beta: expect
      # schema/module changes vs 4.x — re-verify programs.noctalia options
      # and the seeded settings.json after bumping. Move to the stable v5.0.0 tag
      # once it ships.
      url = "github:noctalia-dev/noctalia-shell/v5.0.0-beta2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # noctalia-greeter — greetd greeter that mirrors Noctalia Shell's look.
    # Tracks main (no tagged releases yet). Bump with `nix flake update
    # noctalia-greeter`.
    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    oh-my-pi = {
      url = "github:can1357/oh-my-pi";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Terminal workspace manager for AI coding agents (panes, sessions
    # that survive detach). Tag-pinned to keep client + server in lockstep;
    # bump by editing the `v0.7.x` in the URL below (plain `nix flake
    # update herdr` won't move a tag-pinned ref).
    herdr = {
      url = "github:ogulcancelik/herdr/v0.7.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── SECURE BOOT ────────────────────────────────────────────────
    # Uncomment to enable lanzaboote. Do this ONLY after the system is
    # installed and booting (see secure-boot.md). Enabling it before
    # enrolling keys will leave you unbootable if you flip Secure Boot on.
    # lanzaboote = {
    #   url = "github:nix-community/lanzaboote/v1.0.0";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  # Only the inputs referenced directly in this file are destructured; the
  # rest (noctalia, herdr, …) are reached as `inputs.<name>` from the module
  # tree via specialArgs + extraSpecialArgs (hosts/common.nix wires both).
  outputs =
    { nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib;

      # Every directory under ./hosts is a machine. Drop in a new
      # hosts/<hostname>/ (a default.nix + its hardware-configuration.nix) and
      # it becomes nixosConfigurations.<hostname> automatically — no edit to
      # this file. hosts/common.nix is a FILE and doesn't match the directory
      # filter. scripts/new-host.sh scaffolds one; see hosts/README.md.
      hostNames = builtins.attrNames (
        lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./hosts)
      );

      # A host is one directory under ./hosts: its default.nix imports
      # hosts/common.nix (the shared module trees + home-manager wiring),
      # ./hardware-configuration.nix, and any roles (modules/nixos/roles/)
      # and per-host home overrides (./home.nix) it needs.
      mkHost =
        hostname:
        lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/${hostname}

            # ── SECURE BOOT ──
            # Uncomment together with the input in the inputs block and the
            # block in modules/nixos/core/boot.nix; the module is wired in
            # hosts/common.nix (commented there too):
            # inputs.lanzaboote.nixosModules.lanzaboote
          ];
        };
    in
    {
      nixosConfigurations = lib.genAttrs hostNames mkHost;

      # `nix fmt` formats all .nix files in the tree. pkgs.nixfmt is the RFC 166
      # implementation that ships in nixpkgs. The tree is already nixfmt-clean
      # and CI enforces it (`nix fmt --check` in .github/workflows/check.yml),
      # so running this is a no-op unless you introduced drift.
      formatter = lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ] (
        sys: nixpkgs.legacyPackages.${sys}.nixfmt
      );
    };
}

# Noctalia shell — the single owner of the desktop's look.
{
  config,
  lib,
  pkgs,
  inputs,
  systemSettings,
  ...
}:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # home-manager gained its own modules/programs/noctalia.nix upstream, which
  # declares the same `programs.noctalia` options as the module imported from
  # the noctalia flake above. Two declarations of one option is a hard eval
  # error ("option ... is already declared"), so drop home-manager's copy and
  # keep upstream Noctalia's — it tracks the v5 schema this file is written
  # against and runs `noctalia config validate` at build time.
  #
  # Revisit when home-manager's module matures: if it gains equivalent
  # coverage, switching to it would let us drop the import above. Compare with:
  #   nix eval .#nixosConfigurations.dev.options.home-manager.users.gosha20777.programs.noctalia
  disabledModules = [ "programs/noctalia.nix" ];

  programs.noctalia = {
    enable = true;
    # Run Noctalia as a systemd user unit (PartOf/WantedBy=wayland.systemd.target,
    # Restart=on-failure) instead of letting the compositor spawn it. Two reasons:
    #   1. `nixos-rebuild switch` doesn't kill the running noctalia; without
    #      systemd owning the process, activation leaves the old store-path bar
    #      alive and next startup adds a second one (dup bars — see PR #51).
    #   2. In v5, `noctalia msg …` transparently spawns a full bar when it
    #      can't reach a server (a client/server version mismatch during a
    #      partial rebuild used to give us a stray extra bar). systemd ensures
    #      the running server always matches the current generation.
    # The module wires X-Restart-Triggers to the config.toml source path, so a
    # settings change alone triggers a clean unit restart — no manual bounce.
    systemd.enable = true;

    # Declarative base config → ~/.config/noctalia/config.toml (v5's TOML
    # format; the module runs `noctalia config validate` at build time).
    #
    # v5 splits config into two files and this is why we can own config.toml
    # declaratively where v4 forced a home.activation seed: config.toml is the
    # read-only BASE the shell never writes, and every runtime change from the
    # settings UI (including the chosen wallpaper, which drives the Material You
    # palette) is written to a SEPARATE ~/.local/state/noctalia/settings.toml
    # overrides file that Noctalia merges on top. So a store-path symlink here
    # can't clobber the user's live tweaks — they live in settings.toml, which
    # home-manager doesn't touch.
    settings = {
      # Weather + where-am-I. v5 moved the unit under [weather]; [location]
      # geocodes `address`.
      location.address = "";
      weather = {
        enabled = true;
        unit = "celsius";
      };

      # Theme derives from the wallpaper (Material You), same as v4's matugen
      # behavior — this is what feeds the gtk3/gtk4 templates below and, in
      # turn, our @import'd gtk.css and downstream per-app templates.
      #
      # `wallpaper_scheme` is intentionally unset — the palette follows the
      # wallpaper's hues via the Noctalia default (m3-tonal-spot). Override
      # here to pin a neutral look if desired; valid values are m3-tonal-spot,
      # m3-content, m3-fruit-salad, m3-rainbow, m3-monochrome, vibrant,
      # faithful, dysfunctional, muted (only applies while source = "wallpaper").
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
        # v5 replaces v4's single `gtk` template with two builtin templates
        # writing ~/.config/gtk-{3,4}.0/noctalia.css (the paths our managed
        # gtk.css @imports). Opt into them explicitly. Discover ids with
        # `noctalia theme --list-templates` (builtin) or api.noctalia.dev
        # /templates (community).
        templates = {
          enable_builtin_templates = true;
          builtin_ids = [
            "gtk3"
            "gtk4"
            # NOTE: each of these writes a `noctalia` theme file AND appends an
            # include/palette line to the app's MAIN config.
            #   btop     — plain/writable config, applies cleanly.
            #   ghostty  — migrated: `theme = noctalia` set declaratively above
            #              so apply.sh no-ops on the config; only the theme file
            #              is written. (issue #62)
            #   starship — migrated: config seeded writable so apply.sh can
            #              inject the palette (see modules/home/cli/starship.nix
            #              + the starshipConfigSeed activation). (issue #62)
            #   niri     — migrated: the `include "noctalia.kdl"` line is added
            #              declaratively via the xdg.configFile.niri-config
            #              override in modules/home/desktop/niri.nix, so
            #              apply.sh's has-include grep short-circuits and only
            #              noctalia.kdl gets written (as a regular file, not
            #              through HM). (issue #62)
            "btop"
            "starship"
            "niri"
          ];
          # Community templates are fetched from api.noctalia.dev/templates at
          # runtime and cached under
          # ~/.local/state/noctalia/community-templates (a network fetch, not a
          # Nix-pinned input — offline first-boot won't have them until the
          # shell can reach the API).
          #
          # IMPORTANT: these two id lists are only the BASE. The moment you
          # touch the template checkboxes in Noctalia's settings UI, it writes
          # its own `[theme.templates]` block into
          # ~/.local/state/noctalia/settings.toml, and that block wins over
          # everything here — permanently, for both builtin_ids and
          # community_ids. Adding an id below then does nothing at runtime: the
          # template is never fetched and never applied, with no error anywhere.
          # (That is exactly how `bat` sat unthemed while being listed here.)
          # To actually enable one, tick it in the UI, or stop the shell and
          # remove the stale block from settings.toml. Check what is really in
          # effect with:
          #   grep -A3 'theme.templates' ~/.local/state/noctalia/settings.toml
          enable_community_templates = true;
          community_ids = [
            "bat"
            "neovim"
            "obsidian"
            "vscode"
          ];
        };
      };

      wallpaper = {
        enabled = true;
        directory = "~/Pictures/Wallpapers";
        # Initial wallpaper on a fresh $HOME (the asset seeded by
        # home.activation.wallpapers in modules/home/desktop/wallpapers.nix).
        # The Material You palette is derived from this image
        # (theme.source = "builtin" above keeps the palette on Catppuccin, so
        # changing the wallpaper does NOT re-colour the desktop).
        #
        # Once the user picks another in the UI, that choice lands in
        # ~/.local/state/noctalia/settings.toml and wins over this — so
        # editing this line does NOT change a machine that's already been
        # set up. Use `noctalia msg wallpaper-set <path>` for that.
        default.path = "~/Pictures/Wallpapers/wp12390197-dark-blue-aesthetic-laptop-wallpapers.jpg";
      };

      # v5 folds the polkit agent into native config; this replaces v4's
      # plugins.json `polkit-agent`. niri-flake's polkit-kde-agent stays
      # force-disabled in modules/nixos/core/niri.nix so the two don't race.
      shell.polkit_agent = true;

      # Idle escalation, native to Noctalia's idle manager. Named behaviors
      # under [idle.behavior.*]: a 10-min lock, then suspend-then-hibernate at
      # 15 min. `noctalia:session lock` is the internal action; the bare
      # systemctl command is run as a user command. See services.swayidle
      # in modules/home/desktop/swayidle.nix for the one job (lock-on-lid-close)
      # this can't cover.
      idle.behavior = {
        lock = {
          timeout = 600;
          command = "noctalia:session lock";
          enabled = true;
        };
      };
    };
  };

  # Needed for Noctalia's GTK theming pipeline:
  # - python3 runs Scripts/python/src/theming/gtk-refresh.py (postProcess hook)
  # - glib provides gsettings, which the script calls to push color-scheme
  #   and gtk-theme into org.gnome.desktop.interface so GTK3/4 apps reload.
  home.packages = with pkgs; [
    python3
    glib
  ];
}

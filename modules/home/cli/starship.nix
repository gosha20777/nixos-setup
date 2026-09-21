# starship — prompt. Noctalia owns the palette (issue #62). The `starship`
# builtin template writes ~/.cache/noctalia/starship-palette.toml and its
# apply.sh injects a `[palettes.noctalia]` block into
# ~/.config/starship.toml between markers. That in-place edit REQUIRES a
# writable config, so — unlike ghostty — we can't let home-manager own
# starship.toml as a read-only store symlink (settings must be empty or HM
# writes the file and Noctalia clobbers it). Instead we keep
# programs.starship enabled only for the shell init and seed a writable
# base config in home.activation.starshipConfigSeed below.
#
# The base TOML lives in modules/data/starship-base.toml. Module styles
# reference Noctalia's palette color NAMES, which are Catppuccin-compatible
# (text/subtext/overlay/…) — NOT the old accent/dim/faint/bright/fg. Remap
# under m3-monochrome (all grayscale):
#   accent/git_status → subtext1   bright/root → text
#   fg/directory      → text       dim  → overlay1   faint → overlay0
# The [palettes.noctalia] table itself is deliberately NOT defined here —
# Noctalia injects it; defining it too would make a duplicate TOML table.
{
  config,
  pkgs,
  ...
}:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  # Writable base config for starship (see above). Noctalia's starship
  # template edits ~/.config/starship.toml in place to inject its palette,
  # so this file cannot be a read-only home-manager symlink. We seed the
  # declarative base (module styles, palette name — but NOT the palette
  # table, which Noctalia appends) into a plain writable file. Change-detected
  # against the store path of the base: on a fresh $HOME or whenever the base
  # content below changes we (re)write it, otherwise we leave the file alone so
  # Noctalia's injected [palettes.noctalia] block survives rebuilds. After a
  # (re)seed the block is briefly absent until Noctalia next applies the theme
  # (shell start / wallpaper change) — starship just falls back to defaults in
  # the meantime.
  home.activation.starshipConfigSeed = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      DEST="$HOME/.config/starship.toml"
      STAMP="$HOME/.cache/noctalia/.starship-base-src"
      SRC="${pkgs.writeText "starship-base.toml" (builtins.readFile ../../data/starship-base.toml)}"
      ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$DEST")" \
                                     "$(${pkgs.coreutils}/bin/dirname "$STAMP")"
      if [ ! -f "$DEST" ] || \
         [ "$(${pkgs.coreutils}/bin/cat "$STAMP" 2>/dev/null)" != "$SRC" ]; then
        ${pkgs.coreutils}/bin/rm -f "$DEST"
        ${pkgs.coreutils}/bin/install -m 0644 "$SRC" "$DEST"
        printf '%s' "$SRC" > "$STAMP"
      fi
    '';
  };
}

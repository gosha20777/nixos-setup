# bat — syntax-highlighted `cat` (aliases in shells/*.nix).
#
# Noctalia owns the palette via its community `bat` template (enabled in
# community_ids in modules/home/desktop/noctalia.nix): the template writes
# ~/.config/bat/themes/noctalia.tmTheme from the current Material palette,
# then apply.sh appends `--theme=noctalia` to ~/.config/bat/config and runs
# `bat cache --build` so the theme registers.
#
# That in-place edit requires a writable config. Not setting
# programs.bat.config here is NOT sufficient to get one: enabling
# programs.ghostty flips its `installBatSyntax` (which defaults to
# `package != null`), and that sets `programs.bat.config.map-syntax`
# behind our back — home-manager's bat module materializes bat/config
# whenever `config != {}`, so the file became a read-only store symlink
# anyway. apply.sh opens with `touch "$config_file"` under
# `set -euo pipefail`, which fails on it and aborts the whole script.
#
# So force the option set empty to free the path, and re-add ghostty's
# map-syntax line in the writable seed below. mkForce only clears
# `config`; `programs.bat.syntaxes.ghostty` still installs
# bat/syntaxes/ghostty.sublime-syntax (a separate file, no collision) and
# the module's batCache hook still runs, so ghostty-config highlighting is
# preserved.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs.bat.enable = true;
  programs.bat.config = lib.mkForce { };

  # bat base config — writable, for the same reason as the starship seed in
  # modules/home/cli/starship.nix (see the long note above). Carries the
  # `--map-syntax` line that home-manager's ghostty module would otherwise
  # inject via programs.bat.config, which is exactly what used to materialize
  # this path as a read-only symlink. `--theme=noctalia` is deliberately NOT
  # set here: Noctalia's apply.sh appends it and strips any pre-existing
  # `--theme=` line, so declaring it would just be overwritten. Re-seeding on
  # a content change drops that appended line, but the template re-appends on
  # the next palette apply (or a `noctalia msg session ...`-triggered
  # re-theme).
  home.activation.batConfigSeed = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      DEST="${config.xdg.configHome}/bat/config"
      STAMP="$HOME/.cache/noctalia/.bat-base-src"
      SRC="${pkgs.writeText "bat-base-config" ""}"
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

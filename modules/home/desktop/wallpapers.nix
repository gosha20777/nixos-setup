# Wallpaper library — seeds ~/Pictures/Wallpapers with the assets in
# ./assets/wallpapers/ (repo root). Copy-once per file: if a wallpaper
# already exists at the destination (user replaced it, deleted-and-recreated
# it, or picked up one from a previous rebuild), we leave it alone. The user
# is free to delete a shipped wallpaper — it'll reappear on the next rebuild
# UNLESS they also remove it from ./assets/wallpapers/. Noctalia scans this
# directory at runtime; the file named in
# programs.noctalia.settings.wallpaper.default.path
# (modules/home/desktop/noctalia.nix) becomes the seed selection until the
# user picks another in the UI (which lands in
# ~/.local/state/noctalia/settings.toml and wins).
{
  pkgs,
  ...
}:
{
  home.activation.wallpapers = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      DIR="$HOME/Pictures/Wallpapers"
      SRC_DIR="${../../../assets/wallpapers}"
      ${pkgs.coreutils}/bin/mkdir -p "$DIR"
      for src in "$SRC_DIR"/*; do
        [ -f "$src" ] || continue
        dest="$DIR/$(${pkgs.coreutils}/bin/basename "$src")"
        if [ ! -e "$dest" ]; then
          ${pkgs.coreutils}/bin/install -m 0644 "$src" "$dest"
        fi
      done
    '';
  };
}

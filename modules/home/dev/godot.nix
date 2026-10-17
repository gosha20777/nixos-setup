{ pkgs, ... }:
let
  godotWrapped = pkgs.symlinkJoin {
    name = "godot-wayland";
    paths = [ pkgs.godot_4 ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for bin in godot godot4 godot4.7; do
        if [ -e "$out/bin/$bin" ]; then
          rm "$out/bin/$bin"
          makeWrapper "${pkgs.godot_4}/bin/$bin" "$out/bin/$bin" \
            --set GODOT_WAYLAND_DISABLE_LIBDECOR 1 \
            --add-flags "--display-driver wayland" \
            --add-flags "--single-window"
        fi
      done

      if [ -d "$out/share/applications" ]; then
        rm -rf "$out/share/applications"
        mkdir -p "$out/share/applications"
        substitute "${pkgs.godot_4}/share/applications/org.godotengine.Godot4.7.desktop" \
          "$out/share/applications/org.godotengine.Godot4.7.desktop" \
          --replace-fail "${pkgs.godot_4}/bin/godot" "$out/bin/godot"
      fi
    '';
  };
in
{
  home.packages = [
    godotWrapped
  ];
}

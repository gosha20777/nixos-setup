# Nemo configuration — Cinnamon's file manager
{
  pkgs,
  lib,
  systemSettings,
  ...
}:
let
  # GVariant 'ay' (byte array) type constructor for strings.
  # Nemo's gschema defines `bulk-rename-tool` as type="ay", which rejects
  # standard string values (type="s") with a type mismatch warning.
  mkByteArray =
    str:
    lib.gvariant.mkArray (
      map (c: lib.gvariant.mkUchar (lib.strings.charToInt c)) (lib.stringToCharacters str)
    );
in
{
  dconf.settings = {
    # Default terminal emulator for Nemo's "Open in Terminal" context menu
    "org/cinnamon/desktop/applications/terminal" = {
      exec = "${systemSettings.terminal}";
    };

    # Allow custom keyboard accelerators in GTK/Cinnamon apps
    "org/cinnamon/desktop/interface" = {
      can-change-accels = true;
    };

    # Declarative Nemo preferences
    "org/nemo/preferences" = {
      show-hidden-files = false;
      show-advanced-permissions = true;
      date-format = "locale";
      click-policy = "double";
      show-toggle-extra-pane-toolbar = true;
      tooltips-in-icon-view = false;
      tooltips-in-list-view = false;
      # Thumbnail generation: 128 MB limit (safe for 100MB TIFFs without memory spikes)
      thumbnail-limit = lib.gvariant.mkUint64 134217728;
      show-image-thumbnails = "always";
      # Batch rename utility: bulky (invoked on F2 / Rename with multiple selection)
      bulk-rename-tool = mkByteArray "bulky";
    };

    "org/nemo/preferences/menu-config" = {
      selection-menu-open-as-root = false;
      selection-menu-open-in-new-tab = false;
    };
  };

  # F4 shortcut for "Open in Terminal" in the current directory
  home.file.".gnome2/accels/nemo".text = ''
    (gtk_accel_path "<Actions>/DirViewActions/OpenInTerminal" "F4")
  '';

  # Nemo Context Actions (right-click menu)
  home.file.".local/share/nemo/actions/open-in-art.nemo_action".text = ''
    [Nemo Action]
    Name=Open in ART
    Comment=Open selected image(s) in ART
    Exec=ART %F
    Icon-Name=art
    Selection=notnone
    Extensions=jpg;jpeg;png;tif;tiff;dng;cr2;cr3;nef;arw;raf;orf;pef;rw2;raw;
    Dependencies=ART;
  '';

  home.file.".local/share/nemo/actions/open-in-gthumb.nemo_action".text = ''
    [Nemo Action]
    Name=Open in gThumb
    Comment=Open selected image(s) or folder in gThumb
    Exec=gthumb %F
    Icon-Name=gthumb
    Selection=notnone
    Extensions=any;
    Dependencies=gthumb;
  '';

}

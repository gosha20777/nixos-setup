# Nemo configuration — Cinnamon's file manager
{
  systemSettings,
  ...
}:
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
      show-hidden-files = true;
      show-advanced-permissions = true;
      date-format = "iso";
      click-policy = "double";
      show-toggle-extra-pane-toolbar = true;
      tooltips-in-icon-view = false;
      tooltips-in-list-view = false;
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
}

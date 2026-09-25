{
  pkgs,
  systemSettings,
  ...
}:
let
  theme = import ../../themes/${systemSettings.theme};
in
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Python syntax highlighting, debugging & LSP (Pylance)
      ms-python.python
      ms-python.vscode-pylance
      ms-python.debugpy

      # Nix language support & syntax highlighting
      jnoortheen.nix-ide
    ];
  };

  # Writable settings seed for VS Code (matching the repository pattern in starship.nix).
  # VS Code and its extensions (Python, Pylance, telemetry) write to settings.json at runtime.
  # A read-only Nix store symlink causes VS Code to throw "Unable to write into user settings
  # because the file is write protected (Readonly)". We merge declarative theme settings into
  # a real writable file (mode 0644) so both theme updates and runtime edits work smoothly.
  home.activation.vscodeSettingsSeed = {
    after = [ "writeBoundary" ];
    before = [ ];
    data =
      let
        themeSettings = pkgs.writeText "vscode-theme-settings.json" (
          builtins.toJSON ({
            "editor.fontSize" = 24;
            "editor.semanticHighlighting.enabled" = true;
            "workbench.colorTheme" = "Default Dark Modern";
            "workbench.colorCustomizations" = theme.vscode.colorCustomizations;
            "editor.tokenColorCustomizations" = theme.vscode.tokenColorCustomizations;
            "editor.semanticTokenColorCustomizations" = theme.vscode.semanticTokenColorCustomizations;
          })
        );
      in
      ''
        DEST="$HOME/.config/Code/User/settings.json"
        ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$DEST")"
        if [ -L "$DEST" ]; then
          ${pkgs.coreutils}/bin/rm -f "$DEST"
        fi
        if [ -f "$DEST" ]; then
          TMP="$(${pkgs.coreutils}/bin/mktemp)"
          ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "$DEST" "${themeSettings}" > "$TMP" && \
            ${pkgs.coreutils}/bin/install -m 0644 "$TMP" "$DEST"
          ${pkgs.coreutils}/bin/rm -f "$TMP"
        else
          ${pkgs.coreutils}/bin/install -m 0644 "${themeSettings}" "$DEST"
        fi
      '';
  };
}

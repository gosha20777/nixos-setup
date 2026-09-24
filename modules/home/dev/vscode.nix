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
    profiles.default.userSettings = {
      "workbench.colorTheme" = "Default Dark Modern";
      "workbench.colorCustomizations" = theme.vscode.colorCustomizations;
      "editor.tokenColorCustomizations" = theme.vscode.tokenColorCustomizations;
      "editor.semanticTokenColorCustomizations" = theme.vscode.semanticTokenColorCustomizations;
    };
  };
}

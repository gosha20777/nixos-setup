# lazygit — git TUI. Colors take YAML list form: [hex, "bold"] etc.
# nerdFontsVersion = "3" to match the JetBrainsMono Nerd Font shipped in
# modules/nixos/core/fonts.nix.
{
  pkgs,
  ...
}:
{
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        nerdFontsVersion = "3";
        theme = {
          activeBorderColor = [
            "#cccccc"
            "bold"
          ];
          inactiveBorderColor = [ "#3c3c3c" ];
          searchingActiveBorderColor = [
            "#dddddd"
            "bold"
          ];
          selectedLineBgColor = [ "#191919" ];
          optionsTextColor = [ "#aaaaaa" ];
          cherryPickedCommitBgColor = [ "#3c3c3c" ];
          cherryPickedCommitFgColor = [ "#cccccc" ];
          markedBaseCommitBgColor = [ "#3c3c3c" ];
          markedBaseCommitFgColor = [ "#cccccc" ];
          unstagedChangesColor = [ "#dddddd" ];
          defaultFgColor = [ "#aaaaaa" ];
        };
      };
    };
  };
}

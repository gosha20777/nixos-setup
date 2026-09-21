{
  pkgs,
  ...
}:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      tree = "eza --tree";
      cat = "bat";
    };
    shellInit = ''
      fish_add_path "$HOME/.local/bin"
    '';
  };
}

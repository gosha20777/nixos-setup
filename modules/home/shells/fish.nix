{
  pkgs,
  ...
}:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --header --git";
      la = "eza -la --icons --group-directories-first --header --git";
      tree = "eza --tree --icons";
      cat = "bat";
    };
    shellInit = ''
      fish_add_path "$HOME/.local/bin"
    '';
  };
}

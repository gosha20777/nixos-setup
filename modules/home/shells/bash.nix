{
  pkgs,
  ...
}:
{
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --group-directories-first --header --git";
      la = "eza -la --icons --group-directories-first --header --git";
      tree = "eza --tree --icons";
      cat = "bat";
    };
    initExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };
}

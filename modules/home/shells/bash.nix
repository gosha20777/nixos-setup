{
  pkgs,
  ...
}:
{
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "eza";
      ll = "eza -l";
      la = "eza -la";
      tree = "eza --tree";
      cat = "bat";
    };
    initExtra = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };
}

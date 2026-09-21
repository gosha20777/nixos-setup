{
  pkgs,
  ...
}:
{
  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}

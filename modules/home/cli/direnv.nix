{
  ...
}:
{
  ############################################################
  # direnv + nix-direnv
  # Automatically activates/deactivates per-project environments.
  # nix-direnv creates local GC roots in .direnv/ so project
  # dependencies are not wiped by nix-collect-garbage / nh clean.
  ############################################################
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global = {
        warn_timeout = "10s";
        hide_env_diff = true;
      };
    };
  };
}

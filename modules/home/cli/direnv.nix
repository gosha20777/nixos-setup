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
    stdlib = ''
      # Expose nix-ld and GPU driver (CUDA/OpenGL) libraries inside direnv projects
      # so Python wheels (PyTorch, OpenCV, CUDA) seamlessly find libcuda.so and C++ runtimes.
      export LD_LIBRARY_PATH="/run/current-system/sw/share/nix-ld/lib:/run/opengl-driver/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    '';
  };
}

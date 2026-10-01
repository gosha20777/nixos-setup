{
  pkgs,
  ...
}:
{
  ############################################################
  # Dynamic Linker Shim for FHS / Pre-built Python Wheels
  # Enables unpatched binaries, PyPI packages (PyTorch, OpenCV),
  # and CUDA libraries without manual patchelf.
  ############################################################
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Base runtime
      stdenv.cc.cc.lib
      zlib
      glib

      # GUI / X11 / Wayland compatibility for OpenCV and Matplotlib
      libGL
      libglvnd
      wayland
      libxkbcommon
      fontconfig
      freetype
      libx11
      libxext
      libxrender
      libice
      libsm
    ];
  };
}

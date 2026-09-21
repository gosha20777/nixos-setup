# C/C++ toolchain basics. `pkgs.gcc` resolves to the current nixpkgs
# default (gcc-wrapper around gcc 14.x at time of writing); pin to
# e.g. `gcc13`/`gcc14` if a project needs a specific ABI. `gnumake`
# is the canonical `make` — most upstream Makefiles assume it.
{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    gcc
    gnumake
  ];
}

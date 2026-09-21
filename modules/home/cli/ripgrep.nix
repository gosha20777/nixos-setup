# crush prefers `rg` for greps; unfound falls back to slower search
{ pkgs, ... }: { home.packages = [ pkgs.ripgrep ]; }

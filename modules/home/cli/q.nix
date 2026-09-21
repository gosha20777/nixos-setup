# q-text-as-data is packaged in nixpkgs, so we pull it in here instead of
# via pipx.
{ pkgs, ... }: { home.packages = [ pkgs.q-text-as-data ]; }

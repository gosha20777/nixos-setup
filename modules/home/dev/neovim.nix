# Neovim + LazyVim starter (from flake input `lazyvim-starter`).
# The starter is fetched at build time and copied to ~/.config/nvim once
# if missing. Read-only symlinks to /nix/store cannot be used because LazyVim
# writes lazy-lock.json and Noctalia's neovim template writes theme overrides:
#   ~/.config/nvim/lua/matugen.lua           — matugen-templated palette
#   ~/.config/nvim/lua/plugins/base16.lua    — LazyVim spec for base16-nvim
# Updates to the starter template via `nix flake update lazyvim-starter` apply
# only to fresh installations; existing configs are user-managed (:Lazy update).
{
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.neovim ];

  # LazyVim starter — copy once from store path, leave existing config alone
  home.activation.lazyvimStarter = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      if [ ! -e "$HOME/.config/nvim" ]; then
        cp -r ${inputs.lazyvim-starter} "$HOME/.config/nvim"
        chmod -R u+w "$HOME/.config/nvim"
      fi
    '';
  };
}

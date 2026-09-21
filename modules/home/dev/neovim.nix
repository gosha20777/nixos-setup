# Neovim + LazyVim starter. Theming owned by Noctalia's community `neovim`
# template (enabled in community_ids, modules/home/desktop/noctalia.nix).
# Its apply.sh writes:
#   ~/.config/nvim/lua/matugen.lua           — matugen-templated palette
#                                              (base16 slots derived from
#                                              Noctalia's Material scheme).
#   ~/.config/nvim/lua/plugins/base16.lua    — LazyVim spec that installs
#                                              RRethy/base16-nvim and calls
#                                              `require('matugen').setup()`.
# Wallpaper changes send SIGUSR1 to running nvim so the palette live-reloads
# without restarting. Both files land inside the LazyVim starter clone
# (home.activation.lazyvimStarter below), which is user-writable —
# home-manager can't (and shouldn't) manage them. If they're missing after
# a fresh install, ensure Noctalia has reached api.noctalia.dev at least once
# and nudge the wallpaper to trigger a template re-apply.
{
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.neovim ];

  # LazyVim starter — clone once, leave existing config alone
  home.activation.lazyvimStarter = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      if [ ! -e "$HOME/.config/nvim" ]; then
        ${pkgs.git}/bin/git clone --depth=1 https://github.com/LazyVim/starter "$HOME/.config/nvim"
        rm -rf "$HOME/.config/nvim/.git"
      fi
    '';
  };
}

# yazi — fast terminal file manager in Rust (image previews in kitty).
{ systemSettings, ... }:
let
  theme = import ../../themes/${systemSettings.theme};
in
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true; # `y` function in fish (cd on quit)
    theme = theme.yazi;
  };
}

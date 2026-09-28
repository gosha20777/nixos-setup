# Limine bootloader UI styling for Everforest Warm theme
{ colors }:
let
  strip = hex: builtins.replaceStrings [ "#" ] [ "" ] hex;
  bgHex = strip colors.bg;
  surfaceHex = strip colors.surfaceDark;
  fgHex = strip colors.fg;
  accentHex = strip colors.accent;
  smokeHex = strip colors.smoke;
in
{
  wallpapers = [ ];
  backdrop = bgHex;

  interface = {
    branding = "ThinkPad · NixOS";
    brandingColor = accentHex;
    helpColor = smokeHex;
    helpColorBright = accentHex;
    helpHidden = false;
  };

  graphicalTerminal = {
    margin = 140;

    background = "FF" + surfaceHex;
    foreground = fgHex;
    brightForeground = accentHex;

    font = {
      scale = "2x2";
      spacing = 1;
    };
  };
}

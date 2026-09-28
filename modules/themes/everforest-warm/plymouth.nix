# Plymouth splash screen configuration for Everforest Warm theme
{ colors }:
let
  strip = hex: builtins.replaceStrings [ "#" ] [ "" ] hex;
in
{
  themeName = "everforest";
  bgColor = strip colors.bg;
  surfaceColor = strip colors.surfaceDark;
  fgColor = strip colors.fg;
  accentColor = strip colors.accent;
}

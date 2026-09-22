# foot — fast, lightweight Wayland terminal (no OpenGL required, works in any
# VM). Secondary terminal: systemSettings.terminalAlt.
{
  pkgs,
  lib,
  systemSettings,
  ...
}:
let
  c = (import ../../themes/${systemSettings.theme}).colors;
  strip = hex: lib.strings.removePrefix "#" hex;
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "xterm-256color";
        font = "JetBrainsMono Nerd Font:size=13";
        dpi-aware = "yes";
        pad = "8x8";
      };
      colors = {
        alpha = 0.92;
        background = strip c.bg;
        foreground = strip c.fg;
        regular0 = strip c.c0;
        regular1 = strip c.c1;
        regular2 = strip c.c2;
        regular3 = strip c.c3;
        regular4 = strip c.c4;
        regular5 = strip c.c5;
        regular6 = strip c.c6;
        regular7 = strip c.c7;
        bright0 = strip c.c8;
        bright1 = strip c.c9;
        bright2 = strip c.c10;
        bright3 = strip c.c11;
        bright4 = strip c.c12;
        bright5 = strip c.c13;
        bright6 = strip c.c14;
        bright7 = strip c.c15;
      };
    };
  };
}

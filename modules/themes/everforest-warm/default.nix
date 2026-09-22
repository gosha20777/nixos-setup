# Everforest Warm Refined — единственный источник цветов системы.
# Потребляется: noctalia.nix (customPalettes), foot.nix, fastfetch.nix,
# niri.nix (niri-effects.kdl из этого каталога). Маппинг ролей Material →
# палитра подобран так, чтобы builtin-шаблоны Noctalia (kitty/niri/starship)
# выдавали ровно tmp/everforest.conf.
rec {
  # Плоские токены для прямых потребителей (foot, fastfetch).
  colors = {
    bg = "#141617";
    fg = "#E1DACB";
    selectionBg = "#2C3C40";
    selectionFg = "#F7F4EC";
    accent = "#9EC468"; # шалфей (sage)
    accent2 = "#65B8C7"; # хвойная волна (pine)
    gold = "#E2B862";
    apricot = "#F2874B";
    coral = "#F26E74";
    surfaceDark = "#282D30";
    smoke = "#828C85";
    # ANSI16
    c0 = "#262B2E";
    c1 = "#F26E74";
    c2 = "#9EC468";
    c3 = "#E2B862";
    c4 = "#65B8C7";
    c5 = "#D67B9D";
    c6 = "#52BFA3";
    c7 = "#E1DACB";
    c8 = "#828C85";
    c9 = "#F2874B";
    c10 = "#AFD874";
    c11 = "#F3C775";
    c12 = "#7BC9D8";
    c13 = "#E592B1";
    c14 = "#69D3B7";
    c15 = "#F7F4EC";
  };

  # Палитра для programs.noctalia.customPalettes.EverforestWarm.
  # Роли подобраны под шаблоны Noctalia:
  #  kitty: active_border=primary(шалфей), inactive=surface_variant,
  #         active_tab_bg=primary/fg=on_primary, url=primary,
  #         cursor_trail_color=on_surface_variant(дымчатый)
  #  niri (наш user-template): active-gradient primary→secondary (шалфей→сосна)
  #  starship: green=normal green(шалфей), blue=normal blue(сосна),
  #            red=normal red(коралл), maroon=bright red(абрикос)
  noctalia = {
    dark = {
      mPrimary = colors.accent;
      mOnPrimary = colors.bg;
      mSecondary = colors.accent2;
      mOnSecondary = colors.bg;
      mTertiary = colors.gold;
      mOnTertiary = colors.bg;
      mError = colors.coral;
      mOnError = colors.bg;
      mSurface = colors.bg;
      mOnSurface = colors.fg;
      mSurfaceVariant = colors.surfaceDark;
      mOnSurfaceVariant = "#8B938D";
      mOutline = colors.selectionBg;
      mShadow = "#101112";
      mHover = colors.selectionBg;
      mOnHover = colors.fg;
      terminal = {
        background = colors.bg;
        foreground = colors.fg;
        cursor = colors.fg;
        cursorText = colors.bg;
        selectionBg = colors.selectionBg;
        selectionFg = colors.selectionFg;
        normal = {
          black = colors.c0;
          red = colors.c1;
          green = colors.c2;
          yellow = colors.c3;
          blue = colors.c4;
          magenta = colors.c5;
          cyan = colors.c6;
          white = colors.c7;
        };
        bright = {
          black = colors.c8;
          red = colors.c9;
          green = colors.c10;
          yellow = colors.c11;
          blue = colors.c12;
          magenta = colors.c13;
          cyan = colors.c14;
          white = colors.c15;
        };
      };
    };
  };
}

# Конфигурация внешнего вида noctalia-greeter под тему Everforest Warm
# Документация: https://docs.noctalia.dev/greeter/configuration/
{
  colors,
  wallpaper ? ../../../assets/wallpapers/01.jpg,
}:
{
  scheme = "Synced";
  theme_mode = "dark";
  font_family = "JetBrainsMono Nerd Font";
  corner_radius_scale = 1.0;
  password_style = "random";

  # Точное соответствие 16 обязательным ключам палитры noctalia-greeter
  palette = {
    primary = colors.accent;
    on_primary = colors.bg;
    secondary = colors.accent2;
    on_secondary = colors.bg;
    tertiary = colors.gold;
    on_tertiary = colors.bg;
    error = colors.coral;
    on_error = colors.bg;
    surface = colors.bg;
    on_surface = colors.fg;
    surface_variant = colors.surfaceDark;
    on_surface_variant = "#8B938D";
    outline = colors.surfaceDark;
    shadow = "#101112";
    hover = "#2C3C40";
    on_hover = colors.fg;
  };

  # Обои экрана входа: фирменные обои темы и графитовая заливка фона
  wallpaper =
    if wallpaper != null then
      {
        path = "${wallpaper}";
        fill_mode = "crop";
        fill_color = colors.bg;
      }
    else
      {
        fill_mode = "crop";
        fill_color = colors.bg;
      };
}

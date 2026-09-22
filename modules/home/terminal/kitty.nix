# Kitty — основной терминал (systemSettings.terminal). Цвета приходят из
# темы: Noctalia builtin-template kitty рендерит
# ~/.config/kitty/themes/noctalia.conf из активной палитры; include ниже
# подключает его (apply.sh при read-only kitty.conf сам ничего не дописывает
# и лишь делает reload — include обязан быть объявлен здесь).
{
  pkgs,
  systemSettings,
  ...
}:
{
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size = 14.0;
      cursor_shape = "beam";
      cursor_trail = 3;
      cursor_trail_decay = "0.1 0.4";
      cursor_trail_start_threshold = 2;
      background_opacity = "0.92";
      window_padding_width = "8 12";
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      url_style = "dotted";
      include = "themes/noctalia.conf";
    };
  };

  # Терминал по умолчанию для lazygit/fzf/xdg-terminal-exec.
  home.sessionVariables.TERMINAL = systemSettings.terminal;
}

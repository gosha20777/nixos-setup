# Telegram Desktop configuration and Everforest Warm theme packaging.
{
  pkgs,
  lib,
  systemSettings,
  ...
}:
let
  theme = import ../../themes/${systemSettings.theme};
  telegramTheme =
    if theme ? telegram then
      pkgs.runCommand "${systemSettings.theme}.tdesktop-theme"
        {
          nativeBuildInputs = [ pkgs.zip ];
        }
        ''
          mkdir theme
          cp ${pkgs.writeText "colors.tdesktop" theme.telegram} theme/colors.tdesktop
          cd theme
          zip -q -9 $out colors.tdesktop
        ''
    else
      null;
in
{
  home.packages = [ pkgs.telegram-desktop ];

  home.file = lib.mkIf (telegramTheme != null) {
    ".local/share/TelegramDesktop/themes/everforest-warm.tdesktop-theme".source = telegramTheme;
  };
}

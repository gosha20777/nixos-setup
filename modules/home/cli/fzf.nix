{
  pkgs,
  systemSettings,
  ...
}:
let
  theme = import ../../themes/${systemSettings.theme};
  colors = theme.colors;
in
{
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;

    defaultCommand = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --exclude .git";
    defaultOptions = [
      "--height 45%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];

    fileWidget = {
      command = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --exclude .git";
      options = [
        "--preview '${pkgs.bat}/bin/bat --color=always --style=numbers,changes --line-range :300 {}'"
      ];
    };

    changeDirWidget = {
      command = "${pkgs.fd}/bin/fd --type d --strip-cwd-prefix --hidden --exclude .git";
      options = [
        "--preview '${pkgs.eza}/bin/eza --tree --icons --level=2 {}'"
      ];
    };

    colors = {
      bg = colors.bg;
      "bg+" = colors.surfaceDark;
      fg = colors.fg;
      "fg+" = colors.fg;
      hl = colors.accent;
      "hl+" = colors.accent;
      info = colors.smoke;
      prompt = colors.accent2;
      pointer = colors.accent;
      marker = colors.gold;
      spinner = colors.gold;
      header = colors.smoke;
      border = colors.surfaceDark;
    };
  };
}

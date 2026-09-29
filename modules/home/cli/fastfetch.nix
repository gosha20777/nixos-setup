# fastfetch — компактный инфо-скрин в стиле Everforest Warm.
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
  home.packages = [ pkgs.fastfetch ];

  xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
    display = {
      color.keys = colors.accent2; # сосна / цвет thinkpad (#65B8C7)
      key.width = 14;
      separator = "  ";
    };
    logo = {
      source = "${../../../assets/icons/nixos-everforest.png}";
      type = "kitty-direct";
      width = 22;
      height = 10;
      padding = {
        left = 1;
        right = 2;
        top = 2;
      };
    };
    modules = [
      {
        type = "title";
        color = {
          user = colors.accent;
          at = colors.smoke;
          host = colors.accent2;
        };
      }
      {
        type = "separator";
        string = "─";
        outputColor = colors.smoke;
      }
      {
        type = "os";
        key = "  OS";
        format = "{pretty-name}";
      }
      {
        type = "host";
        key = " 󰌢 Host";
        format = "{family} ({name})";
      }
      {
        type = "kernel";
        key = " 󰌽 Kernel";
      }
      {
        type = "uptime";
        key = " 󰔚 Uptime";
      }
      {
        type = "wm";
        key = "  WM";
        format = "{pretty-name}";
      }
      {
        type = "shell";
        key = "  Shell";
        format = "{pretty-name}";
      }
      {
        type = "packages";
        key = " 󰏖 Packages";
      }
      {
        type = "cpu";
        key = " 󰻠 CPU";
        format = "{name} ({cores-physical}) @ {freq-max}";
      }
      {
        type = "gpu";
        key = " 󰢮 GPU";
        hideType = "integrated";
        format = "{name}";
      }
      {
        type = "memory";
        key = "  Memory";
        format = "{used} / {total} ({percentage})";
      }
      {
        type = "disk";
        key = " 󰋊 Disk";
        format = "{size-used} / {size-total} ({size-percentage}) - {filesystem}";
      }
      {
        type = "colors";
        key = " 󰸱 Color";
        symbol = "circle";
        brightness = "normal";
      }
    ];
  };
}

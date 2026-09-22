# fastfetch — компактный инфо-скрин: лого NixOS, ключи ANSI-blue (сосна).
{ pkgs, ... }:
{
  home.packages = [ pkgs.fastfetch ];
  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": { "source": "nixos-small", "padding": { "top": 1 } },
      "display": { "separator": "  " },
      "modules": [
        "break",
        { "type": "os", "key": "  󰍹 OS", "keyColor": "blue" },
        { "type": "kernel", "key": "  󰌽 Kernel", "keyColor": "blue" },
        { "type": "host", "key": "  󰌢 Machine", "keyColor": "blue" },
        { "type": "packages", "key": "  󰏖 Packages", "keyColor": "blue" },
        { "type": "cpu", "key": "  󰻠 CPU", "keyColor": "blue" },
        { "type": "memory", "key": "  󰑭 Memory", "keyColor": "blue" },
        "break",
        { "type": "colors", "symbol": "circle" },
        "break"
      ]
    }
  '';
}

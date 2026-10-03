# Noctalia shell — the single owner of the desktop's look.
{
  config,
  lib,
  pkgs,
  inputs,
  systemSettings,
  ...
}:
let
  noctalia-bongocat = pkgs.callPackage ../../packages/noctalia-bongocat { };
  noctalia-keybind-cheatsheet = pkgs.callPackage ../../packages/noctalia-keybind-cheatsheet { };
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # home-manager gained its own modules/programs/noctalia.nix upstream, which
  # declares the same `programs.noctalia` options as the module imported from
  # the noctalia flake above. Two declarations of one option is a hard eval
  # error ("option ... is already declared"), so drop home-manager's copy and
  # keep upstream Noctalia's — it tracks the v5 schema this file is written
  # against and runs `noctalia config validate` at build time.
  #
  # Revisit when home-manager's module matures: if it gains equivalent
  # coverage, switching to it would let us drop the import above. Compare with:
  #   nix eval .#nixosConfigurations.dev.options.home-manager.users.gosha20777.programs.noctalia
  disabledModules = [ "programs/noctalia.nix" ];

  programs.noctalia = {
    enable = true;
    # Run Noctalia as a systemd user unit (PartOf/WantedBy=wayland.systemd.target,
    # Restart=on-failure) instead of letting the compositor spawn it. Two reasons:
    #   1. `nixos-rebuild switch` doesn't kill the running noctalia; without
    #      systemd owning the process, activation leaves the old store-path bar
    #      alive and next startup adds a second one (dup bars — see PR #51).
    #   2. In v5, `noctalia msg …` transparently spawns a full bar when it
    #      can't reach a server (a client/server version mismatch during a
    #      partial rebuild used to give us a stray extra bar). systemd ensures
    #      the running server always matches the current generation.
    # The module wires X-Restart-Triggers to the config.toml source path, so a
    # settings change alone triggers a clean unit restart — no manual bounce.
    systemd.enable = true;

    # Палитра темы → ~/.config/noctalia/palettes/EverforestWarm.json
    # (read-only symlink; Noctalia только читает каталог palettes/).
    # X-Restart-Triggers модуля перезапускают юнит при смене палитры.
    customPalettes = {
      EverforestWarm = (import ../../themes/${systemSettings.theme}).noctalia;
    };

    # Declarative base config → ~/.config/noctalia/config.toml (v5's TOML
    # format; the module runs `noctalia config validate` at build time).
    #
    # v5 splits config into two files: config.toml is the read-only BASE,
    # and runtime changes from settings UI land in ~/.local/state/noctalia/settings.toml.
    settings = {
      location.address = systemSettings.location;
      weather = {
        enabled = true;
        unit = "celsius";
      };

      theme = {
        mode = "dark";
        source = "custom";
        custom_palette = "EverforestWarm";
        templates = {
          enable_builtin_templates = true;
          builtin_ids = [
            "kitty"
            "starship"
            "btop"
            "cava"
            "gtk3"
            "gtk4"
          ];
          enable_community_templates = true;
          community_ids = [
            "bat"
            "neovim"
            "obsidian"
            "vscode"
          ];
          user.niri = {
            input_path = "$XDG_CONFIG_HOME/noctalia/templates/niri.kdl";
            output_path = "$XDG_CONFIG_HOME/niri/noctalia.kdl";
            post_hook = "bash '{{ config_dir }}/niri/apply.sh' apply";
          };
        };
      };

      wallpaper = {
        enabled = true;
        directory = "~/Pictures/Wallpapers";
        default.path = "~/Pictures/Wallpapers/01.jpg";
      };

      backdrop.enabled = true;

      shell = {
        avatar_path = "~/Pictures/Avatars/me.jpg";
        polkit_agent = true;
        font_family = "JetBrainsMono Nerd Font";
      };

      # Парящая капсула (floating pill bar): отступ от краёв 45px (для оптимального
      # баланса и достаточного пространства на scale 1.3), отплытие от верхней
      # кромки 6px, лёгкая прозрачность с блюром (layer-rule).
      bar.default = {
        position = "top";
        background_opacity = 0.85;
        margin_ends = 45;
        margin_edge = 6;
        radius = 16;
        thickness = 34;
        padding = 14;
        widget_spacing = 8;
        concave_edge_corners = false;
        start = [
          "launcher"
          "workspaces"
          "cpu_temp"
          "ram_usage"
          "net_speed"
        ];
        center = [
          "cat"
          "clock"
          "caffeine"
          "audio_visualizer"
        ];
        end = [
          "weather"
          "dictation"
          "tray"
          "keyboard_layout"
          "network"
          "battery"
          "control-center"
        ];
      };

      widget = {
        # Логотип NixOS → меню приложений, тонированный акцентом палитры.
        launcher = {
          custom_image = "${
            pkgs.runCommand "nixos-icon" { nativeBuildInputs = [ pkgs.resvg ]; } ''
              mkdir -p $out
              resvg --width 128 ${../../../assets/icons/nixos.svg} $out/nixos.png
            ''
          }/nixos.png";
          custom_image_colorize = true;
        };
        workspaces = {
          display = "name";
        };
        # CPU/RAM/скорость: плоские виджеты без капсул (capsule-группы рисовались
        # непрозрачными плашками поверх полупрозрачного бара). Огонь + °C,
        # чип + GiB, скорость после RAM. label_min_width фиксирует бокс под
        # текст (8.4 px/симв. JetBrainsMono при fontSizeBody 14), чтобы
        # скачущие цифры не двигали панель.
        cpu_temp = {
          type = "sysmon";
          stat = "cpu_temp";
          display = "text";
          glyph = "flame";
          show_label = true;
          label_min_width = 43.0;
        };
        ram_usage = {
          type = "sysmon";
          stat = "ram_used";
          display = "text";
          glyph = "memory";
          show_label = true;
          label_min_width = 68.0;
        };
        cat = {
          type = "local/bongocat:cat";
          input_devices = [
            "/dev/input/by-path/*-event-kbd"
          ];
          audio_spectrum = false;
        };
        clock.format = "{:%H:%M  %a, %d %b}";
        # Волна в цвет основного текста панели (on_surface = #E1DACB,
        # кремовый Everforest Warm), а не в primary-шалфей. Оба конца
        # градиента — один цвет.
        audio_visualizer = {
          width = 50.0;
          bands = 12;
          mirrored = false;
          centered = false;
          show_when_idle = true;
          color_1 = "on_surface";
          color_2 = "on_surface";
        };
        # Кнопка Control Center (конец end-секции): открывает дефолтную
        # вкладку Home — в отличие от клика по часам (захардкожен "calendar").
        # Глиф — официальная "noctalia"-иконка фабрики.
        control-center = {
          glyph = "settings";
        };
        weather = {
          show_condition = false;
          show_temperature = true;
        };
        dictation.type = "local/dictation:status";
        tray = {
          drawer = true;
        };
        keyboard_layout = {
          show_icon = false;
          show_label = true;
          display = "short";
          hide_when_single_layout = false;
        };
        network = {
          show_label = false;
        };
        # Скорость загрузки: в start-секции после RAM. Стрелка download —
        # дефолтный глиф net_rx из SysmonWidget::glyphName, окрашивается
        # динамическим цветом значения (растёт трафик → теплеет).
        # 6 символов ("85.0k"/"14.8M") = 50.4 px — резервируем 52;
        # артефакт "1000.0k" на границе 1 MB/s живёт один опрос и принят.
        net_speed = {
          type = "sysmon";
          stat = "net_rx";
          display = "text";
          glyph = "download";
          network_speed_unit = "auto";
          network_speed_compact = true;
          show_label = true;
          label_min_width = 52.0;
        };
      };

      plugins.enabled = [
        "local/bongocat"
        "local/dictation"
        "local/keybind-cheatsheet"
      ];
      idle.behavior = {
        lock = {
          timeout = 600;
          command = "noctalia:session lock";
          enabled = true;
        };
      };
    };
  };
  # Шаблон-вход для niri-градиента → read-only symlink,
  # user-template ссылается на него через $XDG_CONFIG_HOME.
  xdg.configFile."noctalia/templates/niri.kdl".source = ../../themes/${systemSettings.theme}/niri.kdl;

  xdg.dataFile."noctalia/plugins/bongocat" = {
    source = "${noctalia-bongocat}/share/noctalia-plugins/bongocat";
    force = true;
  };

  xdg.dataFile."noctalia/plugins/keybind-cheatsheet" = {
    source = "${noctalia-keybind-cheatsheet}/share/noctalia-plugins/keybind-cheatsheet";
    force = true;
  };

  # Needed for Noctalia's GTK theming pipeline:
  # - python3 runs Scripts/python/src/theming/gtk-refresh.py (postProcess hook)
  # - glib provides gsettings, which the script calls to push color-scheme
  #   and gtk-theme into org.gnome.desktop.interface so GTK3/4 apps reload.
  home.packages = with pkgs; [
    python3
    glib
    evtest
  ];
}

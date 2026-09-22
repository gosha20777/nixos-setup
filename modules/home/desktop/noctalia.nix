# Noctalia shell — the single owner of the desktop's look.
{
  config,
  lib,
  pkgs,
  inputs,
  systemSettings,
  ...
}:
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
      location.address = "";
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

      shell = {
        avatar_path = "~/Pictures/Avatars/me.jpg";
        polkit_agent = true;
        font_family = "JetBrainsMono Nerd Font";
      };

      # Парящая капсула (floating pill bar): отступ от краёв 180px, отплытие
      # от верхней кромки 6px, лёгкая прозрачность с блюром (layer-rule).
      bar.default = {
        position = "top";
        background_opacity = 0.85;
        margin_ends = 180;
        margin_edge = 6;
        radius = 16;
        thickness = 34;
        padding = 14;
        widget_spacing = 8;
        concave_edge_corners = false;
        start = [
          "launcher"
          "workspaces"
        ];
        center = [
          "cat"
          "clock"
        ];
        end = [
          "media"
          "keyboard_layout"
          "sysmon"
          "network"
          "battery"
          "control-center"
          "session"
        ];
        capsule_group = [
          {
            members = [
              "keyboard_layout"
              "sysmon"
              "network"
              "battery"
            ];
          }
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
          show_labels = true;
          label_source = "name";
        };
        clock.format = "{:%H:%M  %a, %d %b}";
        sysmon.stat = "cpu_temp";
        media.hide_when_no_media = true;
        keyboard_layout = {
          show_glyph = true;
          show_label = true;
          display = "short";
          hide_when_single_layout = false;
        };
        cat.type = "noctalia/bongocat:cat";
      };

      plugins.enabled = [ "noctalia/bongocat" ];

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

  # Needed for Noctalia's GTK theming pipeline:
  # - python3 runs Scripts/python/src/theming/gtk-refresh.py (postProcess hook)
  # - glib provides gsettings, which the script calls to push color-scheme
  #   and gtk-theme into org.gnome.desktop.interface so GTK3/4 apps reload.
  home.packages = with pkgs; [
    python3
    glib
  ];
}

# niri — input, keybinds, and the config.kdl composition with noctalia.kdl.
# The bind set is identical on every host; only outputs differ (per-host,
# via hosts/<name>/home.nix).
{
  config,
  lib,
  pkgs,
  systemSettings,
  ...
}:
{
  # niri input — natural scrolling, tap-to-click, disable-while-typing.
  # Schema is validated at build time by niri-flake.
  programs.niri.settings = {
    input.touchpad = {
      tap = true;
      natural-scroll = true;
      dwt = true;
    };
    # Monitor layout: outputs are matched by "make model serial" (more
    # stable than connector names — surviving dock swaps / different DP
    # ports). Discover identifier strings with `niri msg outputs`. Layouts
    # and per-output modes/scales are per-host — hosts/<name>/home.nix.

    # niri upstream default keybinds, verbatim, with the terminal binaries
    # taken from systemSettings (terminal / terminalAlt). The
    # session/media/lock/brightness binds at the bottom of this block were
    # previously owned by DMS's `enableKeybinds`; with Noctalia in charge of
    # the shell UI we wire them directly to the underlying utilities (wpctl,
    # playerctl, brightnessctl, loginctl). Noctalia's own panels are driven
    # over its IPC surface (`noctalia msg <command…>`); Mod+Space toggles the
    # launcher below. Add settings/clipboard/etc. the same way —
    # `noctalia msg --help` lists every command.
    #
    # NOTE: v5 replaced the `noctalia ipc call <target> <fn>` surface with
    # `noctalia msg <command…>`.
    binds = {
      # Help + spawn
      "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];
      "Mod+T".action.spawn = "${systemSettings.terminal}";
      "Mod+Return".action.spawn = "${systemSettings.terminal}";
      "Mod+Shift+Return".action.spawn = "${systemSettings.terminalAlt}";
      # App launcher — Noctalia's, toggled over IPC. v5: `panel-toggle <id>`.
      "Mod+Space".action.spawn = [
        "noctalia"
        "msg"
        "panel-toggle"
        "launcher"
      ];
      # Mod+D is an alias for the same launcher — fuzzel used to live here as
      # a second, separately-themed launcher; it was dropped as redundant.
      "Mod+D".action.spawn = [
        "noctalia"
        "msg"
        "panel-toggle"
        "launcher"
      ];

      # Window
      "Mod+Q".action.close-window = [ ];

      # Column focus (arrows + vim keys)
      "Mod+Left".action.focus-column-left = [ ];
      "Mod+Right".action.focus-column-right = [ ];
      "Mod+H".action.focus-column-left = [ ];
      "Mod+L".action.focus-column-right = [ ];

      # Window focus within column (arrows). Vim J/K is reassigned below
      # to workspace switching — niri's workspaces only run vertically,
      # so J/K is the natural fit for them.
      "Mod+Down".action.focus-window-down = [ ];
      "Mod+Up".action.focus-window-up = [ ];

      # Vim-style workspace focus. Mod+U/I below still works as a
      # secondary binding (niri upstream default).
      "Mod+J".action.focus-workspace-down = [ ];
      "Mod+K".action.focus-workspace-up = [ ];

      # Column / window move (Ctrl = move). Vim Ctrl+J/K mirrors the
      # focus binding above and moves the current column to the
      # workspace below/above. Arrow Ctrl+Down/Up keeps within-column
      # window movement so that primitive isn't lost.
      "Mod+Ctrl+Left".action.move-column-left = [ ];
      "Mod+Ctrl+Right".action.move-column-right = [ ];
      "Mod+Ctrl+H".action.move-column-left = [ ];
      "Mod+Ctrl+L".action.move-column-right = [ ];
      "Mod+Ctrl+Down".action.move-window-down = [ ];
      "Mod+Ctrl+Up".action.move-window-up = [ ];
      "Mod+Ctrl+J".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+K".action.move-column-to-workspace-up = [ ];

      # First / last column
      "Mod+Home".action.focus-column-first = [ ];
      "Mod+End".action.focus-column-last = [ ];
      "Mod+Ctrl+Home".action.move-column-to-first = [ ];
      "Mod+Ctrl+End".action.move-column-to-last = [ ];

      # Monitor focus (Shift = monitor)
      "Mod+Shift+Left".action.focus-monitor-left = [ ];
      "Mod+Shift+Right".action.focus-monitor-right = [ ];
      "Mod+Shift+Down".action.focus-monitor-down = [ ];
      "Mod+Shift+Up".action.focus-monitor-up = [ ];
      "Mod+Shift+H".action.focus-monitor-left = [ ];
      "Mod+Shift+L".action.focus-monitor-right = [ ];
      "Mod+Shift+J".action.focus-monitor-down = [ ];
      "Mod+Shift+K".action.focus-monitor-up = [ ];

      # Move column to monitor (Shift+Ctrl)
      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [ ];
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [ ];
      "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [ ];
      "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [ ];
      "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [ ];
      "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [ ];

      # Workspace focus / move (Page keys + u/i)
      "Mod+Page_Down".action.focus-workspace-down = [ ];
      "Mod+Page_Up".action.focus-workspace-up = [ ];
      "Mod+U".action.focus-workspace-down = [ ];
      "Mod+I".action.focus-workspace-up = [ ];
      "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [ ];
      "Mod+Ctrl+U".action.move-column-to-workspace-down = [ ];
      "Mod+Ctrl+I".action.move-column-to-workspace-up = [ ];
      "Mod+Shift+Page_Down".action.move-workspace-down = [ ];
      "Mod+Shift+Page_Up".action.move-workspace-up = [ ];
      "Mod+Shift+U".action.move-workspace-down = [ ];
      "Mod+Shift+I".action.move-workspace-up = [ ];

      # Scroll wheel = workspaces / columns
      "Mod+WheelScrollDown" = {
        cooldown-ms = 150;
        action.focus-workspace-down = [ ];
      };
      "Mod+WheelScrollUp" = {
        cooldown-ms = 150;
        action.focus-workspace-up = [ ];
      };
      "Mod+Ctrl+WheelScrollDown" = {
        cooldown-ms = 150;
        action.move-column-to-workspace-down = [ ];
      };
      "Mod+Ctrl+WheelScrollUp" = {
        cooldown-ms = 150;
        action.move-column-to-workspace-up = [ ];
      };
      "Mod+WheelScrollRight".action.focus-column-right = [ ];
      "Mod+WheelScrollLeft".action.focus-column-left = [ ];
      "Mod+Ctrl+WheelScrollRight".action.move-column-right = [ ];
      "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [ ];
      "Mod+Shift+WheelScrollDown".action.focus-column-right = [ ];
      "Mod+Shift+WheelScrollUp".action.focus-column-left = [ ];
      "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [ ];
      "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [ ];

      # Numeric workspace switch + move
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;
      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;
      "Mod+Shift+5".action.move-column-to-workspace = 5;
      "Mod+Shift+6".action.move-column-to-workspace = 6;
      "Mod+Shift+7".action.move-column-to-workspace = 7;
      "Mod+Shift+8".action.move-column-to-workspace = 8;
      "Mod+Shift+9".action.move-column-to-workspace = 9;

      # Previous workspace toggle
      "Mod+Tab".action.focus-workspace-previous = [ ];

      # Consume / expel
      "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
      "Mod+BracketRight".action.consume-or-expel-window-right = [ ];
      "Mod+Period".action.expel-window-from-column = [ ];

      # Sizing
      "Mod+R".action.switch-preset-column-width = [ ];
      "Mod+Shift+R".action.switch-preset-window-height = [ ];
      "Mod+Ctrl+R".action.reset-window-height = [ ];
      "Mod+F".action.maximize-column = [ ];
      "Mod+Shift+F".action.fullscreen-window = [ ];
      "Mod+Ctrl+F".action.expand-column-to-available-width = [ ];
      "Mod+C".action.center-column = [ ];
      "Mod+Ctrl+C".action.center-visible-columns = [ ];
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      # Floating + tabbed display
      "Mod+V".action.toggle-window-floating = [ ];
      "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [ ];
      "Mod+W".action.toggle-column-tabbed-display = [ ];

      # Screenshots
      "Print".action.screenshot = [ ];
      "Ctrl+Print".action.screenshot-screen = [ ];
      "Alt+Print".action.screenshot-window = [ ];

      # Session
      "Mod+Shift+E".action.quit = [ ];
      "Mod+Shift+P".action.power-off-monitors = [ ];
      "Mod+Ctrl+Shift+T".action.toggle-debug-tint = [ ];

      # Lock. Noctalia does NOT subscribe to logind's Lock signal, so
      # `loginctl lock-session` is a no-op here — lock through Noctalia's IPC,
      # which raises its WlSessionLock directly.
      "Super+Alt+L".action.spawn = [
        "noctalia"
        "msg"
        "session"
        "lock"
      ];

      # Media keys — PipeWire sinks via wpctl, transport via playerctl.
      "XF86AudioRaiseVolume".action.spawn = [
        "wpctl"
        "set-volume"
        "@DEFAULT_AUDIO_SINK@"
        "5%+"
      ];
      "XF86AudioLowerVolume".action.spawn = [
        "wpctl"
        "set-volume"
        "@DEFAULT_AUDIO_SINK@"
        "5%-"
      ];
      "XF86AudioMute".action.spawn = [
        "wpctl"
        "set-mute"
        "@DEFAULT_AUDIO_SINK@"
        "toggle"
      ];
      "XF86AudioMicMute".action.spawn = [
        "wpctl"
        "set-mute"
        "@DEFAULT_AUDIO_SOURCE@"
        "toggle"
      ];
      "XF86AudioPlay".action.spawn = [
        "playerctl"
        "play-pause"
      ];
      "XF86AudioNext".action.spawn = [
        "playerctl"
        "next"
      ];
      "XF86AudioPrev".action.spawn = [
        "playerctl"
        "previous"
      ];

      # Brightness — keyboard top row.
      "XF86MonBrightnessUp".action.spawn = [
        "brightnessctl"
        "s"
        "5%+"
      ];
      "XF86MonBrightnessDown".action.spawn = [
        "brightnessctl"
        "s"
        "5%-"
      ];
    };
  };

  # Extend niri's generated config.kdl with an `include "noctalia.kdl"` line
  # so noctalia's builtin `niri` template's separately-written noctalia.kdl
  # actually applies. programs.niri.config's `default` is not merge-able (any
  # override replaces the settings-derived default entirely), so we compose
  # our own file by reusing programs.niri.finalConfig — the already-rendered
  # string of settings — and appending the include line.
  #
  # `niri validate` (which validated-config-for would run) rejects a config
  # whose included file doesn't exist. That file is written at runtime by
  # noctalia, not at build time, so we bypass validated-config-for and use
  # pkgs.writeText directly — settings themselves are still type-checked at
  # Nix eval time by niri-flake, so the only unchecked thing is our one-line
  # include, which is worth the trade.
  #
  # apply.sh's grep pattern `^[[:space:]]*include([[:space:]].*)?"([^"]*/)?
  # noctalia\.kdl"([[:space:]]|$)` matches the line we inject, so noctalia's
  # apply-time short-circuit fires and it never tries to write into
  # config.kdl (which is still an HM store-path symlink).
  xdg.configFile.niri-config.source = lib.mkForce (
    pkgs.writeText "config.kdl" ''
      ${config.programs.niri.finalConfig}
      include "noctalia.kdl"
    ''
  );
}

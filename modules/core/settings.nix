# systemSettings — the one place hosts override deployment-level defaults.
# Declared once here, consumed by modules/nixos/core/* and every home-manager
# module (passed in via home-manager.extraSpecialArgs in hosts/common.nix).
# A host overrides any of these with a plain value, e.g.
#   systemSettings.terminal = "kitty";
# Only options with real consumers live here — extend when a need appears.
{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.systemSettings = {
    username = mkOption {
      type = types.str;
      default = "gosha20777";
      description = "Primary (and only) user on every host.";
    };
    gitUsername = mkOption {
      type = types.str;
      default = "gosha20777";
      description = "git commit author name (home/dev/git.nix).";
    };
    gitEmail = mkOption {
      type = types.str;
      default = "gosha20777@users.noreply.github.com";
      description = "git commit author email (home/dev/git.nix).";
    };
    terminal = mkOption {
      type = types.str;
      default = "kitty";
      description = "Primary terminal — used by niri binds and $TERMINAL.";
    };
    terminalAlt = mkOption {
      type = types.str;
      default = "foot";
      description = "Secondary terminal — niri Mod+Shift+Return.";
    };
    theme = mkOption {
      type = types.str;
      default = "everforest-warm";
      description = "Active theme directory under modules/themes/ (palette for Noctalia, niri effects, foot, fastfetch).";
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
{
  # noctalia-greeter on tty1 — a Quickshell-based login screen that mirrors
  # Noctalia Shell's palette/wallpaper (imperative sync via Settings → Shell →
  # Security → Noctalia Greeter → Sync Now — see TODO.md). The greeter's
  # NixOS module sets services.greetd.enable + default_session.command with
  # mkDefault, so no explicit greetd block is needed here.
  #   - allow_empty_password: fprintd's PAM module answers the password
  #     prompt with an empty reply after a fingerprint match; without this
  #     the greeter rejects that reply as invalid credentials.
  #   - keyboard.layout: greeter runs before the session's input config, so
  #     the layout has to be told explicitly.
  programs.noctalia-greeter = {
    enable = true;
    settings = {
      auth.allow_empty_password = false;
      keyboard.layout = "us";
    };
  };
}

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  ############################################################
  # niri + greetd (noctalia-greeter) login
  ############################################################
  programs.niri.enable = true;
  # niri-flake's `programs.niri.package` defaults to niri-stable (v25.08).
  # Pin to niri-unstable because Quickshell-based shells (Noctalia and the
  # ecosystem that shares its Wayland-protocol footprint) track niri's
  # latest, and the stable tag lags. Also disable the in-build cargo test
  # suite — those tests sometimes SIGABRT inside the Nix build sandbox
  # (filesystem assumptions that don't hold), even when the binary itself
  # works at runtime. We don't gain confidence by running niri's own tests
  # during our system build.
  programs.niri.package =
    (inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable).overrideAttrs
      (old: {
        doCheck = false;
      });

  # Polkit auth agent: defer to Noctalia's native polkit agent (enabled via
  # programs.noctalia.settings.shell.polkit_agent in modules/home/desktop/noctalia.nix)
  # rather than niri-flake's bundled polkit-kde-agent service. Two agents would race on the
  # org.freedesktop.PolicyKit1.AuthenticationAgent bus name; the upstream
  # plugin docs explicitly require the other agent to be disabled. Force
  # the unit off — niri-flake hard-codes `wantedBy = [ "niri.service" ]`
  # with no opt-out option, so this is the only knob.
  systemd.user.services.niri-flake-polkit.enable = lib.mkForce false;

  # Tear out GNOME left behind by the Calamares base install. Harmless
  # to keep on if you used the manual install path (nothing to disable).
  services.xserver.enable = false;
  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = false;
}

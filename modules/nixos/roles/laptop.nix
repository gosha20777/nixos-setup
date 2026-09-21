# Laptop role — NOT auto-imported. Include explicitly in a laptop host's
# default.nix:
#   imports = [ ../../modules/nixos/roles/laptop.nix ];
#
# Carries everything that only makes sense on battery-powered, lid-closable
# hardware: suspend-then-hibernate escalation and the power daemons.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Idle escalation timing (Noctalia in modules/home/desktop/noctalia.nix
  # triggers the actions via programs.noctalia.settings.idle.behavior):
  # lock @ 10 min, then `systemctl suspend-then-hibernate` @ 15 min. That
  # suspends to RAM and, HibernateDelaySec later, wakes and hibernates to
  # disk — hibernate lands at 3h 15m total idle. The long delay favors
  # quick lid-open resume for the common short-break case; hibernate still
  # catches the laptop before the battery drains overnight.
  systemd.sleep.settings.Sleep.HibernateDelaySec = 10800; # 3h

  # Closing the lid suspends to RAM, then hibernates HibernateDelaySec later —
  # the same suspend-then-hibernate escalation the idle timeout uses. Applies
  # on battery and AC (HandleLidSwitchExternalPower defaults to this value);
  # HandleLidSwitchDocked defaults to "ignore", so an external display keeps
  # the session alive with the lid shut.
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  services.fwupd.enable = true;
  # power-profiles-daemon, NOT tlp — TLP misbehaves on Framework/Ryzen
  # platforms; see CLAUDE.md "Power" before swapping them.
  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;
  # Noctalia's battery widget (and any UPower consumer) needs the daemon
  # registered on the system bus; without it the shell logs
  # `org.freedesktop.DBus.Error.ServiceUnknown` and silently drops battery
  # state. power-profiles-daemon doesn't pull it in on its own.
  services.upower.enable = true;
}

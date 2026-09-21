# Per-host home overrides for the dev VM — merges on top of the shared
# modules/home tree.
{ pkgs, ... }:
{
  # SPICE session agent: vdagentd (enabled in default.nix) only exposes the
  # virtio channel; the per-session agent is what gives the guest a
  # client-side cursor (no duplicated host cursor) and a shared clipboard.
  # niri / wlroots compositors never spawn it themselves — GNOME does, we
  # don't — so tie it to the graphical session explicitly.
  systemd.user.services.spice-vdagent = {
    Unit = {
      Description = "SPICE session agent (cursor, clipboard sharing)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.spice-vdagent}/bin/spice-vdagent";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Pin the VM output to the host's 1920x1080 panel. niri (like all
  # wlroots compositors) does not implement SPICE-agent dynamic resolution,
  # so the mode can't follow the viewer window — set it statically instead.
  programs.niri.settings.outputs."Virtual-1".mode = {
    width = 1920;
    height = 1080;
  };
}

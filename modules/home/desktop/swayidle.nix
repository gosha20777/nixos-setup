# swayidle — one job only: lock before a sleep Noctalia didn't initiate.
{
  config,
  pkgs,
  ...
}:
{
  # The idle escalation is driven entirely by Noctalia's own idle manager,
  # configured declaratively via programs.noctalia.settings.idle.behavior
  # (modules/home/desktop/noctalia.nix):
  #
  #   - LOCK (10 min): [idle.behavior.lock] timeout=600, `noctalia:session lock`.
  #     Locks via WlSessionLock — the ONLY path that works, since Noctalia
  #     ignores logind's Lock signal, so `loginctl lock-session` is a no-op.
  #   - SUSPEND-THEN-HIBERNATE (15 min): [idle.behavior.hibernate] timeout=900
  #     running `systemctl suspend-then-hibernate` as a user command. Suspends
  #     to RAM, then hibernates after HibernateDelaySec (3h,
  #     modules/nixos/roles/laptop.nix) — hibernate at 3h 15m.
  #
  # swayidle is kept for the ONE thing a Noctalia idle command can't do: lock
  # before a sleep Noctalia didn't initiate — namely a lid close (logind's
  # HandleLidSwitch). Its before-sleep hook holds a logind sleep inhibitor and
  # raises Noctalia's lock via IPC ahead of ANY suspend/hibernate, so the
  # screen is never left unlocked on resume. No timeouts here — they live in
  # Noctalia.
  #
  # The before-sleep command resolves noctalia by absolute store path:
  # swayidle.service runs under user@.service's app.slice with a minimal PATH
  # that does NOT inherit the niri/login-shell PATH where `programs.noctalia`
  # puts the binary. Bare `noctalia` would fail with `command not
  # found`, which is exactly what lid close did before this fix.
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "${config.programs.noctalia.package}/bin/noctalia msg session lock";
    };
  };
}

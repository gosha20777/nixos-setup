# mise for per-project runtime pins (python/node/go)
#
# nix-ld (modules/nixos/core/nix-ld.nix) is what makes mise's pre-built
# binaries runnable on NixOS at all — without it the linker path under
# /lib64 404s and nothing launches. The settings below tune *which*
# pre-built binaries mise reaches for.
#
# python.compile / node.compile = false force mise to use the precompiled
# binaries (python-build-standalone for python; nodejs.org tarballs for
# node) rather than building from source via python-build / node-build.
# Compiling needs a full build toolchain on PATH (gcc, make, openssl-dev,
# bzip2-dev, readline-dev, sqlite-dev, …) — exactly the FHS-shaped pile of
# dev libs NixOS doesn't make convenient. Both also default to "try
# precompiled, fall back to compile" and the fallback path is silent;
# pinning to `false` turns it into a loud failure instead of a 5-minute
# source build that ends in `make: command not found`. go is precompiled
# only — no equivalent knob — and nix-ld alone covers it at runtime.
{
  pkgs,
  ...
}:
{
  programs.mise = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    globalConfig = {
      tools = {
        python = "latest";
        node = "lts";
        pnpm = "latest";
        go = "latest";
      };
      settings = {
        python.compile = false;
        node.compile = false;
      };
    };
  };

  # Materialize mise-managed tools at rebuild time, not lazily on first
  # shell. `programs.mise.globalConfig.tools` (above) only writes the TOML;
  # the actual download happens on `mise install` or when a shell with the
  # activate hook touches a directory whose config references the tool.
  # That's why `which go` could 404 right after a rebuild even though the
  # eval line is in the shell rc — go hadn't been installed yet. Running
  # `mise install` here makes the rebuild authoritative for what's on disk.
  #
  # The pipe to systemd-cat sends both stdout and stderr into the journal
  # under the `mise-install` identifier — `journalctl -t mise-install`
  # surfaces any failure that `|| true` would otherwise swallow. Kept
  # non-fatal so a transient network hiccup can't block the rebuild;
  # mise will retry on next switch or shell.
  home.activation.miseInstall = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      ${pkgs.mise}/bin/mise install --yes 2>&1 \
        | ${pkgs.systemd}/bin/systemd-cat -t mise-install -p info \
        || true
    '';
  };
}

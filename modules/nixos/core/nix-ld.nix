{
  config,
  lib,
  pkgs,
  ...
}:
{
  ############################################################
  # Non-Nix dynamic binaries (mise / pre-built toolchains)
  #
  # mise downloads upstream pre-built binaries — node from nodejs.org,
  # go from go.dev, python from python-build-standalone — that are all
  # linked against /lib64/ld-linux-x86-64.so.2 and a handful of common
  # shared libraries. NixOS doesn't have an FHS, so without a shim those
  # binaries fail to launch with "No such file or directory" pointing at the
  # linker. `programs.nix-ld` installs a stub at the canonical linker
  # path and uses the `libraries` list as the search path for the .so
  # files those binaries dlopen at runtime.
  #
  # Scope is intentional: this is only for mise-managed toolchains.
  # Everything Nix-native (everything in pkgs / home.packages) ignores
  # nix-ld and resolves through the usual store paths.
  ############################################################
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++ / libgcc_s — node's V8, many node native modules
      zlib # python zlib, node zlib bindings, gzipped tarballs unpacked at runtime
      openssl # python _ssl, node tls
      libffi # python ctypes
      ncurses # python _curses, readline backend
      readline # python readline
      bzip2 # python _bz2
      xz # python _lzma
      sqlite # python sqlite3
    ];
  };
}

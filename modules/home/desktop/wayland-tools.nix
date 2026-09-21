# Wayland / niri ergonomics.
{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    wl-clipboard
    # macOS-style aliases for wl-copy / wl-paste so muscle memory works:
    # `echo foo | pbcopy`, `pbpaste`. pbcopy is a bare wl-copy symlink;
    # pbpaste is a wrapper that adds `--no-newline` to match macOS pbpaste
    # — wl-paste's default appends a \n, which doubles up when the copied
    # content already ends in one (e.g. anything piped from `echo`).
    (writeShellScriptBin "pbcopy" ''exec ${wl-clipboard}/bin/wl-copy "$@"'')
    (writeShellScriptBin "pbpaste" ''exec ${wl-clipboard}/bin/wl-paste --no-newline "$@"'')
    brightnessctl
    playerctl
    matugen
    xwayland-satellite
  ];
}

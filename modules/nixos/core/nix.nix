{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  ############################################################
  # Nix / nixpkgs
  ############################################################
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  # Default download buffer is 1 MiB, which fills constantly on big builds
  # (first install, niri/noctalia/claude-code together). 256 MiB silences the
  # "download buffer is full" warnings without meaningful memory cost.
  nix.settings.download-buffer-size = 256 * 1024 * 1024;
  # GC is handled by nh (programs.nh.clean in modules/nixos/core/nh.nix)
  # with a generation limit (--keep 3) instead of a fixed time window.
  nix.gc.automatic = false;
  nixpkgs.config.allowUnfree = true; # google-chrome, typora
  nixpkgs.overlays = [
    (final: prev: {
      # Upstream nixpkgs bug in VS Code 1.136: VS Code loads TextMate/Oniguruma WASM
      # from `resources/app/node_modules.asar.unpacked/vscode-oniguruma/release/onig.wasm`.
      # Without this symlink, `_loadVSCodeOnigurumaWASM` throws "TypeError: Failed to fetch"
      # and syntax highlighting breaks completely across all languages (fixed upstream in 0f47f225).
      vscode = prev.vscode.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          ln -s "$out/lib/vscode/resources/app/node_modules" "$out/lib/vscode/resources/app/node_modules.asar.unpacked"
        '';
      });
    })
  ];
  system.stateVersion = "26.05";
}

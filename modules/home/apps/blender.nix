{
  lib,
  osConfig,
  pkgs,
  ...
}:
{
  home.packages = lib.optionals (builtins.elem osConfig.networking.hostName [
    "pc"
    "lab"
  ]) [ (pkgs.callPackage ../../packages/blender-bin.nix { }) ];
}

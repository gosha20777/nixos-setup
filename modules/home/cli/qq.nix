# JFryy/qq — jq-like CLI with interchangeable format transcodings, built
# from the derivation in modules/packages/qq.nix.
# pipx + jsongrep are still NOT installed via Nix (build-time deps in
# current nixos-unstable cycle through transient failures). Install manually
# post-boot (mise provides python):
#   pip install --user pipx
#   pipx ensurepath
#   pipx install jsongrep
{
  pkgs,
  ...
}:
{
  home.packages = [ (pkgs.callPackage ../../packages/qq.nix { }) ];
}

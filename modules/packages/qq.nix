# JFryy/qq — jq-like CLI with interchangeable format transcodings. Not in
# nixpkgs; packaged here so it survives reinstalls instead of needing a
# post-boot `go install`. Called via pkgs.callPackage from modules/home/cli/qq.nix.
{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "qq";
  version = "0.3.4";
  src = fetchFromGitHub {
    owner = "JFryy";
    repo = "qq";
    rev = "v${version}";
    hash = "sha256-GLZKDKJEtZIsOMj9V7q2Po7DDelhl1tg1DOyihOw2bk=";
  };
  vendorHash = "sha256-x4tEGE/ewE4SjUm9m+NTbKZVLNJsvbNg03Wdw7s4qhI=";
}

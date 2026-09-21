# User avatar at ~/.face (the conventional path login managers, greeters,
# and AccountsService read). Pulled from GitHub; download to a temp file
# and move into place so a failed fetch never leaves a truncated ~/.face.
{
  pkgs,
  ...
}:
{
  home.activation.faceIcon = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      if [ ! -e "$HOME/.face" ]; then
        TMP=$(${pkgs.coreutils}/bin/mktemp)
        if ${pkgs.curl}/bin/curl -fsSL -o "$TMP" "https://avatars.githubusercontent.com/u/44774?v=4"; then
          ${pkgs.coreutils}/bin/mv "$TMP" "$HOME/.face"
        else
          ${pkgs.coreutils}/bin/rm -f "$TMP"
        fi
      fi
    '';
  };
}

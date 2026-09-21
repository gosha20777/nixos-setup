# Impeccable — AI design skill for Claude Code (https://impeccable.style).
# Not in nixpkgs; installed via `npx impeccable install`, which auto-detects
# the coding tool and writes the skill under .claude/skills/. Run from $HOME
# so its "project" install lands in the *global* skills dir (~/.claude/skills/,
# available in every project — same place ~/.claude/skills/fizzy lives).
#
# Two things this hook has to paper over, both because home-manager runs
# activation with a bare PATH (coreutils/findutils/grep/sed only — no node,
# no shell) and no TTY:
#   1. The installer prompts for target + location. Redirecting stdin from
#      /dev/null makes those reads hit EOF and take the defaults
#      (detected-harnesses / project), so it never blocks on a missing TTY.
#   2. npx spawns child processes that need `node` AND a shell on PATH. With
#      the bare activation PATH those fail with `spawn sh ENOENT` / `node:
#      not found` and nothing installs. So prepend nodejs to PATH and point
#      npm's script-shell at bash (nixpkgs bash has bin/bash but no bin/sh,
#      which is exactly the `sh` npm can't find otherwise).
# `.claude` is pre-created so auto-detection resolves to Claude Code on a
# fresh box; guard on the installed skill dir so reruns are a no-op; --yes so
# npx never stops to confirm the one-off package download; `|| true` so a
# network hiccup doesn't fail the rebuild (next switch retries, like
# cyberchef).
{
  pkgs,
  ...
}:
{
  home.activation.impeccable = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      if [ ! -d "$HOME/.claude/skills/impeccable" ]; then
        ${pkgs.coreutils}/bin/mkdir -p "$HOME/.claude"
        ( cd "$HOME" \
          && PATH="${pkgs.nodejs}/bin:$PATH" \
             npm_config_script_shell="${pkgs.bash}/bin/bash" \
             ${pkgs.nodejs}/bin/npx --yes impeccable install </dev/null ) 2>&1 || true
      fi
    '';
  };
}

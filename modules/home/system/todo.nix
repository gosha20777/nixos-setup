# Post-install TODO checklist — generated to ~/TODO.md on a fresh $HOME.
# Everything Nix can't own: credentials, account state, firmware updates,
# imperative one-off downloads.
{
  pkgs,
  ...
}:
{
  home.activation.todoMd = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
            if [ ! -f "$HOME/TODO.md" ]; then
              ${pkgs.coreutils}/bin/cat > "$HOME/TODO.md" <<'TODO'
      # Post-install TODO

      Things the flake can't do for you.

      - [ ] Connect to Wifi (or verify NetworkManager picked it up)
      - [ ] Sign into 1Password (desktop + Chromium extension)
      - [ ] Sign into Gmail
      - [ ] Sign into GitHub: `gh auth login`
      - [ ] Join Tailscale: `sudo tailscale up`
      - [ ] Set up Obsidian Sync + enable Iconize community plugin
      - [ ] Register Typora license
      - [ ] Pick Typora theme: Themes → Noctalia (renamed from "Noctalia Mono" —
            re-pick it if Typora still has the old name selected)
      - [ ] Chromium extensions: sign in to 1Password / Obsidian Web Clipper / Instapaper (the extensions install themselves via modules/nixos/core/apps.nix)
      - [ ] Sign in to Slack, Discord, Signal, Zoom
      - [ ] AnythingLLM Desktop: first launch → Settings → LLM Preference → **Ollama** → Base URL `http://localhost:11434`, then pick a model from `ollama list` (e.g. `gpt-oss:20b`). Data lives under `~/.config/AnythingLLM/` (or `~/.local/share/AnythingLLM/`); nothing is stored in the Nix store.
      - [ ] Download Playdate Simulator: https://play.date/dev/
      - [ ] Check mise toolchains landed: `mise ls` — if python/node/go show `(missing)`, look at `journalctl -t mise-install --since -10m` for the failure, then re-run `mise install`. The rebuild hook is non-fatal by design so a transient network hiccup can't block activation.
      - [ ] Install pipx + jsongrep: `pip install --user pipx && pipx ensurepath && pipx install jsongrep`
      - [ ] Authenticate Claude Code: run `claude`
      - [ ] Authenticate Gemini CLI: `gemini auth`

      - [ ] (Optional) Customize wallpaper in Noctalia — default ships in ~/Pictures/Wallpapers
      - [ ] Sync noctalia-greeter to the shell's palette + wallpaper: Noctalia → Settings → Shell → Security → Noctalia Greeter → Sync Now (writes /var/lib/noctalia-greeter — needs admin creds, not something Nix owns)
      - [ ] Noctalia app themes (bat/zellij/discord/obsidian/zed/steam/…) are community templates fetched from api.noctalia.dev at runtime — offline first-boot won't have them until the shell reaches the network. If they're missing, confirm connectivity and toggle the wallpaper (or restart Noctalia) to re-apply.
      - [ ] Verify the template list actually took effect: `grep -A20 community_ids ~/.local/state/noctalia/settings.toml`. Once the settings UI has written a `[theme.templates]` block there, that list WINS over `community_ids` in modules/home/desktop/noctalia.nix — permanently, and silently. An app listed in the flake but missing from settings.toml is simply never themed, with no error. Fix by ticking it in Noctalia → Settings → Theme → Templates, or by stopping the shell (`systemctl --user stop noctalia`), editing that list, and starting it again.
      - [ ] Pick a wallpaper if you don't want the shipped default — the Material You palette is derived from it, so this re-colours everything. `noctalia msg wallpaper-set <path>` (the flake's `wallpaper.default.path` only seeds a fresh $HOME; settings.toml wins after that).
      - [ ] Crush browser MCPs need Chromium downloaded once:
            `npx -y agent-browser install` and `npx -y @playwright/mcp install chromium`
            (both write to their own ~/.cache dirs — no root; skip if you don't use those MCPs).
      - [ ] Crush's GitHub MCP authenticates via `gh auth token`, so run `gh auth login` (see the GitHub sign-in TODO above) before first launch — otherwise the MCP will 401.
      - [ ] `sudo fwupdmgr update` for BIOS/EC firmware
      - [ ] Set up the backup drive (see modules/nixos/core/backup.nix and backup.md).
            Two manual steps Nix can't own — a physical disk, and a secret:
            1. Label an external drive `timemachine` (ERASES IT):
                 `sudo mkfs.ext4 -L timemachine /dev/sdX1`
               The label is how the config finds it, so any port/enclosure works.
            2. Create the repo password, root-only. Store a copy in 1Password —
               lose this and every snapshot is unreadable, by design:
                 `sudo install -d -m 0700 /etc/restic`
                 `sudo sh -c 'umask 077; head -c 32 /dev/urandom | base64 > /etc/restic/home-password'`
            Then plug the drive in; it mounts and backs up on its own.
            Running, verifying, and restoring are all covered in backup.md.
      - [ ] Test a restore once, while everything still works: recover a file to
            /tmp and diff it (see backup.md). A backup you've never restored
            from is a hypothesis, not a backup.
      TODO
            fi
    '';
  };
}

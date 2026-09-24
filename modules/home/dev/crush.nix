# charmbracelet/crush — terminal AI coding agent. Global config at
# ~/.config/crush/crush.json.
#
# Providers: local Ollama daemon; auto-discovery on empty models list picks
# up everything in `ollama list`, so every model available on the daemon
# becomes selectable immediately.
#
# Top-level `models` binds crush's two agent roles:
#   - large (coder agent): qwen3.8 — 27B with a 256K context and tool use,
#     built for coding and long-horizon agentic work, which is exactly this
#     role. The long context is the real win over gpt-oss:20b for coding:
#     more of a repo fits in one conversation.
#   - small (task agent):  gpt-oss:20b — meant to be the faster of the two.
#     Still larger than ideal; llama3.2 (2 GB, already pulled) would restore
#     a genuine speed difference if task-agent latency ever grates.
#
# MCP servers — mirror what Claude Code would use where it's portable:
#   - context7:      up-to-date library docs; remote HTTP (no auth for
#                    the free tier). Set CONTEXT7_API_KEY via headers if
#                    you hit rate limits.
#   - memory:        knowledge-graph store persisted to
#                    ~/.local/share/crush/memory.json — cross-session
#                    notes crush can query. Approximates (does not
#                    replicate) Claude Code's built-in auto-memory.
#   - github:        official remote GitHub MCP. Auth via $(gh auth token)
#                    at load time — no PAT lives in the repo, and it
#                    rotates whenever `gh auth refresh` runs. If gh isn't
#                    authenticated yet, the header resolves empty and gets
#                    dropped; the MCP will 401 cleanly.
#   - playwright:    browser automation (Microsoft's active replacement
#                    for the archived puppeteer reference server).
#                    First run downloads Chromium under ~/.cache/ms-playwright.
#   - agent-browser: Vercel's browser-automation CLI. Invoked via npx
#                    because pkgs.agent-browser is 0.27.0 and the `mcp`
#                    subcommand only landed in 0.28.0. First run
#                    downloads its bundled Chromium; see TODO.md for the
#                    one-time `agent-browser install` step.
#
# Node is pulled from pkgs.nodejs by absolute store path so crush finds
# `npx` reliably even when PATH is minimal.
#
# NOTE: this is a store-path symlink (read-only). Crush's built-in
# `crush-config` skill writes here to persist model swaps — that call
# will fail. Change providers/models/mcps by editing this block, not from
# inside crush. Project-local `.crush.json` still works for one-off
# overrides in a repo.
{
  config,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.crush ];

  xdg.configFile."crush/crush.json".text = builtins.toJSON {
    "$schema" = "https://charm.land/crush.json";
    providers = {
      ollama = {
        name = "Ollama";
        base_url = "http://localhost:11434/v1/";
        type = "ollama";
      };
    };
    models = {
      large = {
        provider = "ollama";
        model = "qwen3.8";
      };
      small = {
        provider = "ollama";
        model = "gpt-oss:20b";
      };
    };
    mcp = {
      context7 = {
        type = "http";
        url = "https://mcp.context7.com/mcp";
      };
      memory = {
        type = "stdio";
        command = "${pkgs.nodejs}/bin/npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-memory"
        ];
        env = {
          MEMORY_FILE_PATH = "${config.home.homeDirectory}/.local/share/crush/memory.json";
        };
        # First launch cold-downloads the package from npm before stdio is
        # ready; crush's default 15s init window isn't enough. Subsequent
        # launches hit npx's cache and start in <1s.
        timeout = 300;
      };
      github = {
        type = "http";
        url = "https://api.githubcopilot.com/mcp/";
        # Reuse the token gh CLI is already holding — no PAT stored anywhere,
        # rotates whenever `gh auth refresh` runs. Crush expands $(...) at
        # config load; an empty result drops the header (per crush semantics),
        # which the GH MCP will answer with 401 → clean failure if gh isn't
        # authenticated yet.
        headers.Authorization = "Bearer $(${pkgs.gh}/bin/gh auth token)";
      };
      playwright = {
        type = "stdio";
        command = "${pkgs.nodejs}/bin/npx";
        args = [
          "-y"
          "@playwright/mcp"
        ];
        timeout = 300;
      };
      agent-browser = {
        type = "stdio";
        command = "${pkgs.nodejs}/bin/npx";
        args = [
          "-y"
          "agent-browser"
          "mcp"
          "--tools"
          "core,state,debug,tabs"
        ];
        # Longer than the others because agent-browser's postinstall also
        # unpacks its bundled Chromium (~150 MiB) the first time.
        timeout = 600;
      };
    };
  };
}

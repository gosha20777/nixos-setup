# Oh My Pi (omp) — Terminal AI coding agent.
{
  config,
  inputs,
  lib,
  pkgs,
  systemSettings,
  ...
}:
let
  theme = import ../../themes/${systemSettings.theme};
in
{
  home.packages = [
    inputs.oh-my-pi.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Everforest Warm theme for oh-my-pi
  home.file.".omp/agent/themes/everforest-warm.json".text = builtins.toJSON theme.omp;
  xdg.configFile."omp/agent/themes/everforest-warm.json".text = builtins.toJSON theme.omp;
  sops = lib.mkIf systemSettings.sops.enable {
    secrets = {
      openrouter_api_key = { };
      ollama_api_key = { };
      ollama_base_url = { };
      exa_api_key = { };
      tavily_api_key = { };
    };

    templates."omp-env" = {
      path = "${config.home.homeDirectory}/.omp/agent/.env";
      content = ''
        OPENROUTER_API_KEY=${config.sops.placeholder.openrouter_api_key}
        OLLAMA_API_KEY=${config.sops.placeholder.ollama_api_key}
        OLLAMA_BASE_URL=${config.sops.placeholder.ollama_base_url}
        EXA_API_KEY=${config.sops.placeholder.exa_api_key}
        TAVILY_API_KEY=${config.sops.placeholder.tavily_api_key}
      '';
    };

    templates."omp-models" = {
      path = "${config.home.homeDirectory}/.omp/agent/models.yml";
      content = ''
        providers:
          ollama:
            baseUrl: "${config.sops.placeholder.ollama_base_url}"
            apiKey: OLLAMA_API_KEY
            api: openai-completions
            discovery:
              type: ollama
            modelOverrides:
              "qwen-3.8-mtp:latest":
                name: "Qwen 3.8 27B"
      '';
    };
  };

  # Writable base config seed for omp (same pattern as starship.nix).
  # omp mutates config.yml in place on settings/model/theme changes, so
  # this file cannot be a read-only store symlink (which would break on atomic rename).
  # Re-seeded only when the base config definition in Nix changes.
  home.activation.ompConfigSeed = {
    after = [ "writeBoundary" ];
    before = [ ];
    data =
      let
        baseConfig = pkgs.writeText "omp-config.yml" ''
          modelRoles:
            default: google-antigravity/gemini-3.8-flash:medium
            tiny: google-antigravity/gemini-3.5-flash-lite:minimal
            slow: google-antigravity/claude-opus-5-5-medium:high
            commit: google-antigravity/gemini-3.5-flash-lite:minimal
            plan: google-antigravity/gemini-3.1-pro:high
            smol: google-antigravity/gemini-3.5-flash-lite:low
            advisor: openrouter/nvidia/nemotron-3-ultra-550b-a55b:free:medium
            task: google-antigravity/gemini-3.6-flash:medium
            web: google/gemini-2.5-flash
          symbolPreset: nerd
          composer:
            shape: pi
          theme:
            dark: everforest-warm
          setupVersion: 2
          secrets:
            enabled: true
          bashInterceptor:
            enabled: true
          bash:
            patterns:
              - match: rm -rf *
                approval: deny
              - match: "*remove *"
                approval: deny
              - match: sudo *
                approval: prompt
              - match: "*install *"
                approval: prompt
              - match: git add *
                approval: prompt
              - match: git push *
                approval: prompt
          disabledProviders:
            - claude
            - codex
            - gemini
            - opencode
            - cursor
          tools:
            approvalMode: yolo
            approval:
              computer: deny
              generate_image: deny
              security_scan: deny
          cycleOrder:
            - smol
            - default
            - slow
          exa:
            enabled: true
          task:
            maxConcurrency: 4
            maxRecursionDepth: 0
            maxEffort: max
          commands:
            enableOpencodeProject: false
            enableOpencodeUser: false
            enableClaudeProject: false
            enableClaudeUser: false
          defaultThinkingLevel: high
          retry:
            fallbackChains:
              web:
                - web/exa
                - web/tavily
                - web/startpage
                - web/google
                - google-antigravity/gemini-2.5-flash
                - web/firecrawl
                - web/ollama
                - web/duckduckgo
                - web/ecosia
                - web/mojeek
                - web/public
        '';
      in
      ''
        DEST="$HOME/.omp/agent/config.yml"
        STAMP="$HOME/.omp/agent/.config-base-src"
        SRC="${baseConfig}"
        ${pkgs.coreutils}/bin/mkdir -p "$(${pkgs.coreutils}/bin/dirname "$DEST")"
        if [ ! -f "$DEST" ] || \
           [ "$(${pkgs.coreutils}/bin/cat "$STAMP" 2>/dev/null)" != "$SRC" ]; then
          ${pkgs.coreutils}/bin/rm -f "$DEST"
          ${pkgs.coreutils}/bin/install -m 0600 "$SRC" "$DEST"
          printf '%s' "$SRC" > "$STAMP"
        fi
      '';
  };
}

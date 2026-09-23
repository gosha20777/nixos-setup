# Oh My Pi (omp) — Terminal AI coding agent.
{
  config,
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [
    inputs.oh-my-pi.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  sops = {
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
  };

  xdg.configFile."omp/agent/config.yml".text = ''
    modelRoles:
      slow: google-antigravity/gemini-3.1-pro:high
      smol: ollama/qwen-3.6-mtp:latest:medium
      tiny: openrouter/poolside/laguna-s-2.1:free:minimal
      advisor: openrouter/nvidia/nemotron-3-ultra-550b-a55b:free:medium
      task: google-antigravity/gemini-3.6-flash:medium
      commit: openrouter/poolside/laguna-s-2.1:free:low
      plan: google-antigravity/gemini-3.1-pro:high
      web: google/gemini-2.5-flash
      default: google-antigravity/gemini-3.8-flash:high
    symbolPreset: nerd
    theme:
      dark: titanium
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
    composer:
      shape: pi
  '';

  xdg.configFile."omp/agent/models.yml".text = ''
    providers:
      ollama:
        apiKey: OLLAMA_API_KEY
        api: openai-completions
        discovery:
          type: ollama
        modelOverrides:
          "qwen-3.6-mtp:latest":
            name: "Qwen 3.6 27B"
  '';
}

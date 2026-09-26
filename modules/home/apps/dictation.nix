# Voice dictation daemon with Groq AI, native Noctalia Luau bar widget, and declarative YAML config.
{
  config,
  lib,
  pkgs,
  systemSettings,
  ...
}:
let
  noctalia-dictation = pkgs.callPackage ../../packages/noctalia-dictation { };
  configPath = "${config.home.homeDirectory}/.config/noctalia-dictation/config.yaml";
in
{
  home.packages = [ noctalia-dictation ];

  # 1. Noctalia native Luau plugin (linked cleanly from package output, 0 inline code in nix)
  xdg.configFile."noctalia/plugins/catalog.toml" = {
    source = "${noctalia-dictation}/share/noctalia-plugins/dictation/catalog.toml";
    force = true;
  };
  xdg.configFile."noctalia/plugins/dictation" = {
    source = "${noctalia-dictation}/share/noctalia-plugins/dictation";
    force = true;
  };

  # 2. SOPS YAML configuration for the headless daemon
  sops = lib.mkIf systemSettings.sops.enable {
    secrets = {
      groq_api_key = { };
    };

    templates."dictation-config" = {
      path = configPath;
      content = ''
        api_key: "${config.sops.placeholder.groq_api_key}"
        base_url: "https://api.groq.com/openai/v1"
        stt_model: "whisper-large-v3-turbo"
        refinement_model: "qwen/qwen3.8-27b"
        silence_duration_seconds: 3.0
        vad_aggressiveness: 2
        sample_rate: 16000
        system_prompt: |
          Ты — помощник по диктовке промптов и текста.
          Твоя задача — преобразовать распознанный голос в чистый, грамотный и готовый к использованию текст:
          1. Исправь оговорки, заикания, слова-паразиты («э-э», «ну типа», «короче»).
          2. Расставь знаки препинания и заглавные буквы.
          3. Сохрани оригинальный язык (русский, английский или смешанный).
          4. Точно и корректно форматируй технические термины, имена библиотек, флаги CLI и синтаксис кода (например, asyncio, flake.nix, git commit, Docker, Python).
          5. Не добавляй никаких пояснений, комментариев, мета-текста или кавычек от себя. Возвращай ИСКЛЮЧИТЕЛЬНО очищенный текст.
      '';
    };
  };

  # 3. Headless background service
  systemd.user.services.noctalia-dictation = {
    Unit = {
      Description = "Noctalia Voice Dictation Headless Daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${noctalia-dictation}/bin/noctalia-dictation";
      Restart = "on-failure";
      RestartSec = "2s";
      Environment = [
        "NOCTALIA_DICTATION_CONFIG=${configPath}"
      ];
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}

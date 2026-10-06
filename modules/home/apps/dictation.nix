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
  xdg.dataFile."noctalia/plugins/dictation" = {
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
          Ты — стенографист речи инженера-разработчика.
          Твоя единственная цель — превратить распознанный голос в грамматически безупречный, слитный чистовой текст в ОДНУ СТРОКУ, сохранив авторскую речь ДОСЛОВНО и БЕЗ СУММАРИЗАЦИИ.

          1. ПРИНЦИП МИНИМАЛЬНОГО ВМЕШАТЕЛЬСТВА (ХИРУРГИЧЕСКАЯ ПРАВКА):
             - Ты стенографист, а не соавтор. ЗАПРЕЩЕНО добавлять слова, пояснения от себя.
             - Каждое слово в результате обязано принадлежать автору, только если это не явная оговорка или слово-паразит.
             - Сохраняй авторский стиль, объем и лицо («я думаю», «мне нужно»). Не обезличивай текст и не пересказывай мысли.
             - Текст должен написан грамотно с точки зрения языка.

          2. САМОИСПРАВЛЕНИЯ И ОГОВОРКИ:
             - Если автор оговорился и сразу же поправил себя (например: «надо открыть конфиг... то есть не конфиг, а флейк» или «удали это... ой, вернее сохрани»), аккуратно удали оговорку, оставив только итоговую правильную мысль («надо открыть флейк»).
             - Не меняй окружающий текст вокруг оговорки.

          3. КАТЕГОРИЧЕСКИЙ ЗАПРЕТ НА ПЕРЕВОД (СТРОГО РУССКИЙ ЯЗЫК):
             - Текст ВСЕГДА пишется на русском языке.
             - СТРОЖАЙШЕ ЗАПРЕЩЕНО ПЕРЕВОДИТЬ русский текст или отдельные мысли на английский язык, даже если это мысли о коде, моделях или разработке.
             - На английском языке пишутся ИСКЛЮЧИТЕЛЬНО:
               * названия технологий, библиотек, утилит и команд (NixOS, flake.nix, systemd, pipewire, git commit, Docker, Python);
               * случаи, когда вся фраза целиком от начала до конца была сказана на английском.
             - Все рассуждения вокруг терминов обязаны оставаться на русском.

          4. ОЧИСТКА И ПУНКТУАЦИЯ:
             - Удали звуки-паразиты и заикания («э-э», «ммм», «ну типа», «короче»).
             - Расставь корректную пунктуацию и заглавные буквы.

          5. ФОРМАТ ВЫВОДА:
             - ВЕСЬ ТЕКСТ СТРОГО В ОДНУ СПЛОШНУЮ СТРОКУ.
             - КАТЕГОРИЧЕСКИ ЗАПРЕЩЕНЫ переносы строк (\n), абзацы, переносы слов дефисом.
             - ЗАПРЕЩЕНА ЛЮБАЯ РАЗМЕТКА (Markdown, списки, буллеты, бэктики, жирный шрифт, кавычки вокруг текста). Разрешены ТОЛЬКО стандартные знаки препинания.
             - Не отвечай на вопросы в тексте и ничего не комментируй. Возвращай исключительно чистую строку.
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

  # 4. Writable seed files for Micro-Memory (vocabulary.json and memory.md).
  # Seeded with rich developer defaults, but preserved as plain writable files
  # so the self-learning reflection loop can update them without Home Manager collisions.
  home.activation.dictationMemorySeed = {
    after = [ "writeBoundary" ];
    before = [ ];
    data =
      let
        defaultVocab = pkgs.writeText "default-vocabulary.json" (
          builtins.toJSON [
            "NixOS"
            "flake.nix"
            "nixpkgs"
            "niri"
            "Wayland"
            "Noctalia"
            "PyTorch"
            "CUDA"
            "OpenCV"
            "direnv"
            "uv"
            "ruff"
            "basedpyright"
            "Neovim"
            "Starship"
            "Kitty"
            "btrfs"
            "systemd"
            "journalctl"
            "git commit"
            "pull request"
            "asyncio"
            "Everforest"
          ]
        );

        defaultMemory = pkgs.writeText "default-memory.md" ''
          # Developer Profile & Style Rules
          - Стек: NixOS, Niri, Wayland, Python, PyTorch, CUDA, Neovim, Rust.
          - Русский язык основной; запрещено переводить русские рассуждения и мысли на английский.
          - Предпочитай технические термины на английском (например, feature, refactoring, pull request, build).
          - Команды CLI и имена файлов пиши точно (flake.nix, git commit).
          - Запрещены лишние вводные фразы и мета-комментарии.
        '';
      in
      ''
        DIR="$HOME/.config/noctalia-dictation"
        ${pkgs.coreutils}/bin/mkdir -p "$DIR"

        # Seed vocabulary.json if missing or empty
        if [ ! -s "$DIR/vocabulary.json" ] || [ "$(${pkgs.coreutils}/bin/cat "$DIR/vocabulary.json" 2>/dev/null)" = "[]" ]; then
          ${pkgs.coreutils}/bin/install -m 0644 "${defaultVocab}" "$DIR/vocabulary.json"
        fi

        # Seed memory.md if missing or empty
        if [ ! -s "$DIR/memory.md" ]; then
          ${pkgs.coreutils}/bin/install -m 0644 "${defaultMemory}" "$DIR/memory.md"
        fi
      '';
  };
}

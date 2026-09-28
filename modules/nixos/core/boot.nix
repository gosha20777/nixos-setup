{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  theme = import ../../themes/${config.systemSettings.theme};
  colors = theme.colors;

  # Limine expects hex colors without the '#' prefix
  strip = hex: lib.removePrefix "#" hex;

  bgHex = strip colors.bg; # 141617 (глубокий графит темы)
  surfaceHex = strip colors.surfaceDark; # 282D30 (подложка карточки меню)
  fgHex = strip colors.fg; # E1DACB (молочный основной текст)
  accentHex = strip colors.accent; # 9EC468 (шалфей / активный пункт)
  smokeHex = strip colors.smoke; # 828C85 (приглушенные подсказки)

  termBg = "FF" + surfaceHex;

  # Читаем boot-note: сначала локальный для хоста, затем общий из корня репо
  hostNoteFile = ../../../hosts/${config.networking.hostName}/boot-note;
  rootNoteFile = ../../../boot-note;
  rawNote =
    if builtins.pathExists hostNoteFile then
      builtins.readFile hostNoteFile
    else if builtins.pathExists rootNoteFile then
      builtins.readFile rootNoteFile
    else
      "system update";
  bootNote =
    let
      trimmed = lib.strings.trim rawNote;
    in
    if trimmed != "" then trimmed else "system update";
in
{
  ############################################################
  # Boot Loader — Limine (современный графический UEFI загрузчик)
  ############################################################

  # Сохраняем заметку в текущее поколение, чтобы старые поколения помнили свое описание
  environment.etc."boot-note".text = bootNote + "\n";

  # Отключаем systemd-boot в пользу Limine
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.loader.limine = {
    enable = lib.mkDefault true;
    maxGenerations = 3; # автоматическая ротация старых ядер на ESP
    enableEditor = false; # безопасность: запрет ручного ввода init=/bin/sh

    style = {
      # Без картинок: однородная заливка глубоким графитом темы
      wallpapers = [ ];
      backdrop = bgHex;

      interface = {
        branding = "ThinkPad · NixOS";
        brandingColor = accentHex;
        helpColor = smokeHex;
        helpColorBright = accentHex;
        helpHidden = false;
      };

      graphicalTerminal = {
        margin = 140;

        background = termBg;
        foreground = fgHex;
        brightForeground = accentHex;

        font = {
          scale = "2x2";
          spacing = 1;
        };
      };
    };

    # Пост-обработка limine.conf: форматирует заголовки (Generation N (DD.MM HH:MM))
    # и подставляет человеческую заметку из /etc/boot-note в comment: каждого поколения.
    extraInstallCommands = ''
      ${pkgs.python3}/bin/python3 - << 'PYEOF'
      import datetime, os, re, sys

      cfg_paths = [
          "/boot/limine/limine.conf",
          "/efi/limine/limine.conf",
          "/boot/efi/limine/limine.conf",
      ]
      cfg_path = None
      for p in cfg_paths:
          if os.path.exists(p):
              cfg_path = p
              break

      if not cfg_path:
          sys.exit(0)

      try:
          with open(cfg_path, "r", encoding="utf-8") as f:
              content = f.read()

          def enrich_entry(m):
              prefix = m.group(1)      # e.g. "//" or "///"
              plus = m.group(2) or ""  # "+" if present
              gen = m.group(3)
              protocol = m.group(4)
              profile_path = f"/nix/var/nix/profiles/system-{gen}-link"

              date_str = ""
              full_date = ""
              note_str = "system update"

              if os.path.exists(profile_path):
                  try:
                      st = os.lstat(profile_path)
                      dt = datetime.datetime.fromtimestamp(st.st_mtime)
                      date_str = dt.strftime("%d.%m %H:%M")
                      full_date = dt.strftime("%Y-%m-%d")
                  except Exception:
                      pass

                  note_file = os.path.join(profile_path, "etc/boot-note")
                  if os.path.exists(note_file):
                      try:
                          with open(note_file, "r", encoding="utf-8") as nf:
                              n = nf.read().strip()
                              if n:
                                  note_str = n
                      except Exception:
                          pass

              if date_str:
                  title = f"{prefix}{plus}Generation {gen} ({date_str})"
                  comment = f"comment: {note_str} · built on {full_date}"
              else:
                  title = f"{prefix}{plus}Generation {gen}"
                  comment = f"comment: {note_str}"

              return f"{title}\n{protocol}\n{comment}\n"

          pattern = r'(/{1,3})(\+?)Generation\s+(\d+)\n(\s*protocol:\s*[^\n]+)\n\s*comment:\s*[^\n]+\n'
          new_content = re.sub(pattern, enrich_entry, content)

          with open(cfg_path, "w", encoding="utf-8") as f:
              f.write(new_content)
      except Exception as e:
          print(f"warning: limine post-processing failed: {e}", file=sys.stderr)
      PYEOF
    '';
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 2;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Plymouth boot splash screen (Everforest Warm Minimal Theme)
  boot.plymouth = {
    enable = true;
    theme = "everforest";
    themePackages = [
      (pkgs.callPackage ../../packages/plymouth-theme-everforest { })
    ];
    font = "${pkgs.nerd-fonts.jetbrains-mono}/share/fonts/truetype/NerdFonts/JetBrainsMono/JetBrainsMonoNerdFont-Regular.ttf";
  };
  boot.initrd.verbose = false;
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
  ];
}

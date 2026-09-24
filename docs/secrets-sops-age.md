# Управление секретами: sops-nix и Age

Данный документ содержит полное руководство по организации, шифрованию, ротации и безопасному хранению секретов (API-ключей AI-агентов, приватных SSH-ключей и учетных данных) в публичном Git-репозитории.

---

## 1. Архитектурная модель: Единый мастер-ключ Age пользователя

### Почему отказ от хостовых SSH-ключей — правильное решение
В стандартных руководствах по NixOS часто предлагают шифровать секреты публичными SSH-ключами хостов (`/etc/ssh/ssh_host_ed25519_key.pub`).  
**Фундаментальная проблема этого подхода:**
* При переустановке системы или замене диска хостовый SSH-ключ стирается и генерируется заново.
* Репозиторий Git оказывается зашифрован старым ключом, которого больше не существует в природе.
* Приходится либо вручную восстанавливать хостовый ключ перед первым запуском, либо перешифровывать все файлы в репозитории с другой машины.

### Наше решение: Персональный Age-ключ пользователя (Identity Key)
Мы используем **единый персональный ключ Age**, принадлежащий пользователю:
1. Ключ генерируется **один раз**: `age-keygen -o ~/.config/sops/age/keys.txt`.
2. Публичный ключ (`age1...`) коммитится в `.sops.yaml` в корне репозитория.
3. Приватный ключ хранится исключительно локально на машинах и в защищенном резервном хранилище (Chrome Password Manager с 2FA, личный сейф).
4. **Результат:** При чистой переустановке любого хоста (ThinkPad, виртуальной машины или будущего ARM-ноутбука) репозиторий Git **вообще не нужно трогать или перешифровывать**. Достаточно просто положить файл `keys.txt` на новую машину.

---

## 2. Разделение ключей: Публичный замок vs Приватный секрет

| Ключ | Где находится | Назначение | Уровень секретности |
| :--- | :--- | :--- | :--- |
| **Публичный ключ (`age1...`)** | В файле `.sops.yaml` в корне Git | Умеет только **ЗАШИФРОВЫВАТЬ** данные (захлопывать замок). | **Открытый.** Абсолютно безопасно пушить на GitHub (как и публичный SSH-ключ). |
| **Приватный мастер-ключ (`AGE-SECRET-KEY-1...`)** | `~/.config/sops/age/keys.txt` (права `0600`) | Единственный ключ, умеющий **РАСШИФРОВЫВАТЬ** секреты. | **АБСОЛЮТНАЯ ТАЙНА.** Никогда не должен попасть в коммит, лог или публичный доступ. |

---

## 3. Конфигурация маршрутизации `.sops.yaml`

В корне репозитория находится файл `.sops.yaml`:

```yaml
keys:
  - &gosha20777 age1z23l5wjy6lrma8m7tp6dysydwcqg0fvgfwnxq59233mfhwylxscss7hfld

creation_rules:
  - path_regex: secrets/.*\.yaml$
    key_groups:
      - age:
          - *gosha20777
```

* `&gosha20777` — YAML-якорь для публичного мастер-ключа пользователя `gosha20777`.
* `creation_rules` — правило: любые YAML-файлы в каталоге `secrets/` автоматически шифруются этим ключом с использованием шифра **ChaCha20-Poly1305** и обмена ключами **X25519**.

---

## 4. Структура файлов секретов

Все секретные файлы размещаются в каталоге `secrets/` в зашифрованном виде (в Git хранится только шифротекст):

### А. Общие секреты: `secrets/common.yaml`
Секреты, одинаковые для всех машин:
* `openrouter_api_key`: API-токен для моделей OpenRouter.
* `ollama_api_key`: токен авторизации локальной/удаленной Ollama.
* `ollama_base_url`: базовый URL инстанса Ollama.
* `exa_api_key`: API-токен поискового движка Exa.
* `tavily_api_key`: API-токен поискового движка Tavily.

### Б. Хостовые секреты: `secrets/<hostname>.yaml` (например, `secrets/thinkpad.yaml`)
Секреты, принадлежащие строго конкретной физической машине:
* `id_ed25519`: приватный SSH-ключ ноутбука ThinkPad. У других хостов будут свои раздельные файлы (например, `secrets/dev.yaml` или `secrets/arm-laptop.yaml`).

---

## 5. Декларативное потребление секретов в NixOS

Секреты подключаются через Home-Manager без использования сторонних скриптов:

### 1. Базовый модуль: `modules/home/system/sops.nix`
```nix
{ config, lib, systemSettings, ... }:
{
  sops = lib.mkIf systemSettings.sops.enable {
    defaultSopsFile = ../../../secrets/common.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  };
}
```

### 2. Генерация `.env` для Oh My Pi: `modules/home/agents/oh-my-pi.nix`
`sops-nix` на лету создает файл переменных окружения:
```nix
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
};
```

### 3. Восстановление SSH-ключа хоста: `hosts/thinkpad/home.nix`
```nix
sops.secrets."id_ed25519" = {
  sopsFile = ../../secrets/thinkpad.yaml;
  path = "${config.home.homeDirectory}/.ssh/id_ed25519";
  mode = "0600";
};
```

---

## 6. Резервное копирование и экстренное восстановление мастер-ключа

Поскольку файл `~/.config/sops/age/keys.txt` существует локально, критически важно иметь защищенную копию.

### Способ: Сохранение в Google Password Manager (Chrome)
1. Открыть `chrome://password-manager/passwords`.
2. Создать новую запись:
   * **Сайт:** `age-key.local`
   * **Имя пользователя:** `gosha20777`
   * **Пароль:** Вставить строку приватного мастер-ключа (`AGE-SECRET-KEY-1...`).
   * **Заметка (Note):** Описание:
     ```
     NixOS flake sops-nix master key
     Public: age1z23l5wjy6lrma8m7tp6dysydwcqg0fvgfwnxq59233mfhwylxscss7hfld
     Файл на машине: ~/.config/sops/age/keys.txt (0600)
     ```
3. **Безопасность:** Запись синхронизируется через аккаунт Google, защищенный двухфакторной аутентификацией (2FA).

### Восстановление на чистой системе:
```bash
mkdir -p ~/.config/sops/age
echo "AGE-SECRET-KEY-1..." > ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```
После этого система немедленно сможет расшифровать все секреты.

---

## 7. Операционные команды для работы с секретами

```bash
# Редактирование секретов (расшифровывает в памяти, открывает $EDITOR, шифрует при сохранении):
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix shell nixpkgs#sops -c \
  sops secrets/common.yaml

# Просмотр расшифрованного содержимого в stdout:
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix shell nixpkgs#sops -c \
  sops -d --output-type json secrets/common.yaml

# Зашифровать новый файл с нуля:
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix shell nixpkgs#sops -c \
  sops --encrypt --filename-override secrets/common.yaml raw.yaml > secrets/common.yaml

# Перешифровать все файлы после обновления публичных ключей в .sops.yaml:
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt nix shell nixpkgs#sops -c \
  sops updatekeys secrets/common.yaml
```

---

## 8. Правило абсолютной безопасности (Zero-Leak)

* Никогда не коммитить файлы `keys.txt`, `*.key` или `secrets/*.decrypted`.
* Они внесены в `.gitignore`.
* В коде модулей репозитория секреты подставляются исключительно через плейсхолдеры `config.sops.placeholder.<name>`. В Nix Store попадают только имена переменных, а значения расшифровываются исключительно в момент активации на лету.

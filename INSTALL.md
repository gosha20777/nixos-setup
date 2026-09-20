# Руководство по установке NixOS (хост `dev`) в виртуальную машину Gnome Boxes

Инструкция по развертыванию NixOS конфигурации `dev` в виртуальной машине **Gnome Boxes** (QEMU/KVM) на **Fedora Linux**.

Репозиторий размещается в домашней папке пользователя (`~/projects/my_projects/nixos-setup`), избегая засорения системного каталога `/etc/nixos`.

---

## Подготовка

1. Скачайте образ **NixOS Minimal ISO (x86_64-linux)** с официального сайта:
   [https://nixos.org/download](https://nixos.org/download)

2. Откройте **Gnome Boxes** (Боксы):
   - Нажмите `+` -> **Установить из файла** -> выберите скачанный `.iso` файл.
   - Зайдите в **Настройки (Preferences)** созданной VM:
     - **Память (RAM):** от 4 до 8 ГБ (рекомендуется 8 ГБ).
     - **Процессор:** 4+ ядра.
     - **Размер диска:** от 30 ГБ.
   - Запустите виртуальную машину.

---

## Пошаговая установка в Live ISO

После загрузки виртуалка откроется в TTY-консоли NixOS Live ISO.

### 1. Разметка и форматирование диска

Выполните следующие команды для создания разделов UEFI (FAT32) и Btrfs (с подтомами `@`, `@home`, `@nix`):

```bash
# 1. Создание таблицы разделов GPT
sudo parted /dev/vda -- mklabel gpt
sudo parted /dev/vda -- mkpart ESP fat32 1MiB 512MiB
sudo parted /dev/vda -- set 1 boot on
sudo parted /dev/vda -- mkpart primary btrfs 512MiB 100%

# 2. Форматирование разделов
sudo mkfs.fat -F32 -n boot /dev/vda1
sudo mkfs.btrfs -L nixos -f /dev/vda2

# 3. Создание Btrfs подтомов
sudo mount /dev/vda2 /mnt
sudo btrfs subvolume create /mnt/@
sudo btrfs subvolume create /mnt/@home
sudo btrfs subvolume create /mnt/@nix
sudo umount /mnt

# 4. Монтирование файловых систем
sudo mount -o subvol=@,compress=zstd /dev/vda2 /mnt
sudo mkdir -p /mnt/{boot,home,nix}
sudo mount -o subvol=@home,compress=zstd /dev/vda2 /mnt/home
sudo mount -o subvol=@nix,compress=zstd,noatime /dev/vda2 /mnt/nix
sudo mount /dev/vda1 /mnt/boot
```

---

### 2. Клонирование репозитория в целевую систему

Создайте каталог `~/projects/my_projects/` в `/mnt/home/gosha20777/` и склонируйте туда ваш репозиторий:

```bash
# Создаем папку пользователя в целевой системе
sudo mkdir -p /mnt/home/gosha20777/projects/my_projects
sudo chown -R 1000:100 /mnt/home/gosha20777

# Клонируем репозиторий
cd /mnt/home/gosha20777/projects/my_projects
sudo git clone https://github.com/gosha20777/nixos-setup.git nixos-setup
```

*(Или скопируйте файлы репозитория через `scp` / флешку / локальный веб-сервер, если репозиторий еще не в GitHub).*

---

### 3. Запуск установки

Перейдите в папку склонированного репозитория и запустите сборку и установку:

```bash
cd /mnt/home/gosha20777/projects/my_projects/nixos-setup

# Запуск установки для хоста dev
sudo nixos-install --flake .#dev
```

В процессе установки `nixos-install` попросит вас задать:
1. **Пароль для пользователя root**
2. **Пароль для пользователя gosha20777**

Задайте пароли и дождитесь завершения установки.

---

### 4. Перезагрузка и вход

Выполните команду перезагрузки:

```bash
sudo reboot
```

В Gnome Boxes отключите ISO-образ (в свойствах VM уберите устройство CD/DVD), чтобы загрузиться с установленного диска.

После загрузки вас встретит графический экран входа (Noctalia / niri) или TTY. Авторизуйтесь под пользователем `gosha20777`.

---

## Обновление и управление конфигурацией из VM

Так как репозиторий находится в `~/projects/my_projects/nixos-setup`, внесение изменений и их применение в системе выполняется без прав root для git:

```bash
cd ~/projects/my_projects/nixos-setup

# Редактирование файлов, коммиты:
git status
git commit -m "my change"

# Применение изменений к системе:
sudo nixos-rebuild switch --flake .#dev
```

---

## Подключение агента по SSH с Fedora

В конфигурацию `hosts/dev/default.nix` зашит SSH-ключ с вашей системы Fedora (`gosha20777@pc`).

1. Узнайте IP-адрес виртуальной машины внутри VM:
   ```bash
   ip a
   ```
   *(обычно `192.168.122.x`)*

2. С основной системы Fedora подключитесь к VM без пароля:
   ```bash
   ssh gosha20777@192.168.122.X
   ```

3. Теперь агент (или вы) с хост-системы Fedora можете удаленно выполнять любые команды внутри VM:
   ```bash
   ssh gosha20777@192.168.122.X "cd ~/projects/my_projects/nixos-setup && sudo nixos-rebuild switch --flake .#dev"
   ```

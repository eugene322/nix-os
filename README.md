# nix-os

Декларативная конфигурация NixOS: **flakes + home-manager + disko + impermanence
+ sops-nix + stylix**.

Хост `desktop`: Hyprland (Wayland), NVIDIA (open-драйвер), Btrfs c эфемерным
root («erase your darlings»), snapper, бинарные кэши.

## Структура

```
flake.nix                      # инпуты + outputs, всё собирается здесь
hosts/desktop/
  configuration.nix            # тонкий: hostname, stateVersion, imports
  disk-config.nix              # disko: разметка диска (btrfs-сабвольюмы)
  hardware-configuration.nix   # генерится на машине (см. установку), не в git до этого
modules/nixos/                 # переиспользуемые системные модули
  default.nix                  # агрегатор — комментируй строку, чтобы выключить фичу
  nix boot networking locale users security secrets
  impermanence snapper stylix desktop nvidia
home/                          # home-manager для юзера eugene
  default shell git development desktop
templates/                     # стартеры dev-окружений (devenv / flake) под direnv
.sops.yaml.example             # шаблон правил шифрования секретов
```

> ⚠️ Flake видит **только файлы, добавленные в git**. После любой правки делай
> `git add -A`, иначе изменения не попадут в сборку (и можно поймать «file not found»).

---

## 1) Обновить в текущем репозитории (перед установкой)

Правки, которые нужно сделать один раз под свою машину:

1. **Диск** — `hosts/desktop/disk-config.nix`, строка `device`:
   замени `/dev/nvme0n1` на стабильный путь. Узнать: `ls -l /dev/disk/by-id`.
   ```nix
   device = "/dev/disk/by-id/nvme-Samsung_SSD_990_PRO_...";
   ```

2. **Пароль (важно из-за эфемерного root!)** — `modules/nixos/users.nix`.
   Root стирается при каждой загрузке, поэтому пароль, заданный через `passwd`,
   **не переживёт перезагрузку**. Задай его декларативно:
   ```bash
   mkpasswd -m sha-512        # введёшь пароль, получишь хэш $6$...
   ```
   ```nix
   users.users.eugene.hashedPassword = "$6$...";   # вставь хэш
   ```
   (Позже можно перенести в sops — см. раздел 4 «Секреты».)

3. **SSH-ключ** — `modules/nixos/users.nix`. В `security.nix` вход по паролю
   через SSH выключен, так что добавь свой публичный ключ:
   ```nix
   users.users.eugene.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA... you@host" ];
   ```

4. **Часовой пояс / локаль** — `modules/nixos/locale.nix` (по умолчанию
   `Europe/Kyiv`, `en_US.UTF-8`). Поправь при необходимости.

5. Зафиксируй:
   ```bash
   git add -A
   ```

---

## 2) Первая установка (с live-ISO)

Загрузись с официального NixOS live-ISO, подключи сеть, затем:

```bash
# 0. включить flakes в live-окружении
export NIX_CONFIG="experimental-features = nix-command flakes"

# 1. забрать репозиторий
nix shell nixpkgs#git -c git clone <твой-репозиторий> /tmp/nix-os
cd /tmp/nix-os
#   (при необходимости поправь device в disk-config.nix прямо тут + git add -A)

# 2. РАЗМЕТКА ДИСКА — стирает целевой диск!
sudo nix run github:nix-community/disko -- \
  --mode destroy,format,mount --flake .#desktop
#   после этого подтома смонтированы в /mnt

# 3. создать @-blank — пустой снимок root, к которому откатывается каждая загрузка
#    (делается СЕЙЧАС, пока @ ещё пустой, ДО установки)
MNT=$(mktemp -d)
sudo mount -o subvol=/ /dev/disk/by-label/nixos "$MNT"
sudo btrfs subvolume snapshot -r "$MNT/@" "$MNT/@-blank"
sudo umount "$MNT"

# 4. сгенерировать hardware-configuration.nix (без filesystems — их даёт disko)
sudo nixos-generate-config --no-filesystems --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix \
        /tmp/nix-os/hosts/desktop/hardware-configuration.nix
#    раскомментируй ./hardware-configuration.nix в hosts/desktop/configuration.nix
#    и сделай git add -A

# 5. положить репозиторий на постоянный подтом (/home переживает wipe)
sudo mkdir -p /mnt/home/eugene/workspace
sudo cp -r /tmp/nix-os /mnt/home/eugene/workspace/nix-os

# 6. установить систему
sudo nixos-install --flake /mnt/home/eugene/workspace/nix-os#desktop

# 7. (если НЕ задал hashedPassword в шаге 1.2) выставить временный пароль —
#    помни: переживёт перезагрузку только декларативный пароль
sudo nixos-enter --root /mnt -c 'passwd eugene'

reboot
```

После перезагрузки в initrd сработает откат `@` к `@-blank`, система поднимется
с чистого root, а состояние подтянется из `/persist`, `/home`, `/nix`.

---

## 3) При последующих запусках (обычная загрузка)

Делать ничего не нужно — но полезно понимать, что происходит:

- **`/` (`@`) стирается** при каждой загрузке (откат к `@-blank` в initrd).
- **Переживает перезагрузку** только то, что лежит на отдельных подтомах
  (`/home`, `/nix`, `/persist`, `/var/log`) или перечислено в
  `modules/nixos/impermanence.nix` (NetworkManager-соединения, bluetooth,
  ssh host keys, machine-id, `/var/lib/nixos` …).
- Нашёл состояние, которое пропадает после ребута и должно жить? — добавь путь
  в `environment.persistence."/persist"` в `impermanence.nix`, затем `rebuild`.
- Снимки `/home` и `/persist` делает snapper (см. `snapper.nix`):
  `sudo snapper -c home list`, откат — `sudo snapper -c home undochange A..B`.

---

## 4) Стандартная работа (день за днём)

Репозиторий живёт в `~/workspace/nix-os`. Алиасы заданы в `home/shell.nix`.

**Применить изменения конфига:**
```bash
cd ~/workspace/nix-os
# поправил .nix → ОБЯЗАТЕЛЬНО добавить в git, иначе flake не увидит
git add -A
rebuild            # = sudo nixos-rebuild switch --flake ~/workspace/nix-os#desktop
```

**Обновить пакеты (бамп flake.lock):**
```bash
update             # = nix flake update && rebuild
```

**Откатиться, если что-то сломалось:** выбери прошлый GENERATION в загрузчике,
либо:
```bash
sudo nixos-rebuild switch --rollback
```

**Почистить мусор / старые поколения:**
```bash
cleanup            # = nix-collect-garbage -d && nixos-rebuild boot
```
(GC и так идёт еженедельно автоматически — см. `nix.nix`.)

**Проверить конфиг без применения:**
```bash
nix flake check
nixos-rebuild build --flake .#desktop   # собрать, но не переключаться
nix fmt                                  # формат (nixfmt) — или войти в nix develop
```

**Секреты (sops-nix).** Один раз настроить:
```bash
ssh-to-age < /persist/etc/ssh/ssh_host_ed25519_key.pub   # age-ключ хоста
cp .sops.yaml.example .sops.yaml                          # вписать ключи
nix develop -c sops secrets/secrets.yaml                  # создать/редактировать
```
Затем раскомментировать `defaultSopsFile` и нужные `secrets.*` в
`modules/nixos/secrets.nix` и `rebuild`. Файл `secrets/secrets.yaml`
зашифрован — его и `.sops.yaml` коммитим; приватные ключи — никогда.

**Dev-окружение под проект** (direnv + nix-direnv/devenv):
```bash
cd ~/projects/foo
cp -r ~/workspace/nix-os/templates/devenv/.  .   # или templates/flake/
direnv allow                                     # активируется на cd
```

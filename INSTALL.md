# system

Снимок моей системы на Fedora: niri, waybar, hyprlock, rofi, Alacritty, kitty, Neovim (NvChad), zsh и обои.

## Установка на новый компьютер

```sh
git clone git@github.com:GlebLarkin/system.git
cd system
./install.sh
```

Скрипт подключит нужные COPR-репозитории, поставит пакеты из `packages.txt`, скопирует конфиги и обои, скачает шрифты и курсор, настроит тему и сделает zsh оболочкой по умолчанию. Заменённые файлы он сохраняет в `~/.config-backup-<дата>`.

Только файлы, без пакетов и системных настроек: `./install.sh --configs-only`.

После установки выйди из сессии и выбери niri на экране входа.

## Что сделать вручную

- Выбрать обои через `Win+W`: на новой системе у swww ещё нет сохранённой картинки. Этот же выбор обновит цвета wallust.
- Добавить `~/.env.zsh`, если нужны локальные переменные. Этот файл намеренно не хранится в репозитории.
- Настроить git (`user.name`, `user.email`), SSH-ключи и VPN: их здесь тоже нет.

## Структура

| Путь | Куда копируется |
|---|---|
| `config/` | `~/.config/` |
| `home/` | `~/` |
| `bin/` | `~/.local/bin/` |
| `share/` | `~/.local/share/` |
| `wallpapers/` | `~/Pictures/wallpapers/` |

В `config/hypr/` лежат только hyprlock, hypridle и скрипты, которые вызывает niri. Hyprland как таковой здесь не настраивается.

Настройки MonkeyType лежат в `config/monkey-type/`, их нужно импортировать на сайте.

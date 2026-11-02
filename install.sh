#!/bin/bash
# Restores this system on a fresh Fedora install. Run as a normal user: ./install.sh
# --configs-only: copy files only, without packages, fonts, cursor and system settings.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
COPRS=(solopasha/hyprland erikreider/SwayNotificationCenter errornointernet/packages)
GTK_THEME=Flat-Remix-GTK-Blue-Dark
ICON_THEME=Flat-Remix-Blue-Dark
CURSOR_THEME=Bibata-Modern-Ice
DEFAULT_WALLPAPER=AnimeWaiting.png

install_packages() {
  for copr in "${COPRS[@]}"; do
    sudo dnf copr enable -y "$copr"
  done
  grep -vE '^\s*(#|$)' "$ROOT/packages.txt" | xargs sudo dnf install -y
}

# Moves an existing file aside, then copies the repo version over it.
place() {
  local src="$1" dst="$2"
  if [[ -e "$dst" || -L "$dst" ]]; then
    mkdir -p "$BACKUP/$(dirname "${dst#"$HOME"/}")"
    mv "$dst" "$BACKUP/${dst#"$HOME"/}"
  fi
  mkdir -p "$(dirname "$dst")"
  cp -a "$src" "$dst"
}

install_files() {
  local item
  for item in "$ROOT"/config/*; do
    place "$item" "$HOME/.config/$(basename "$item")"
  done
  for item in "$ROOT"/home/.[!.]*; do
    place "$item" "$HOME/$(basename "$item")"
  done
  place "$ROOT/bin/xdg-terminal-exec" "$HOME/.local/bin/xdg-terminal-exec"
  mkdir -p "$HOME/Pictures/Screenshots"
  place "$ROOT/wallpapers" "$HOME/Pictures/wallpapers"
}

adapt_to_machine() {
  # niri does not expand $HOME in its config strings, so these paths are absolute.
  sed -i "s|/home/gleblarkin|$HOME|g" "$HOME/.config/niri/config.kdl"

  local wifi
  wifi="$(nmcli -t -f DEVICE,TYPE device 2>/dev/null | awk -F: '$2 == "wifi" { print $1; exit }' || true)"
  if [[ -n "$wifi" ]]; then
    sed -i "s|\"interface\": \"wlp2s0\"|\"interface\": \"$wifi\"|" \
      "$HOME/.config/waybar/configs/[TOP] Minimal Glass (niri)"
  else
    echo "Wi-Fi adapter not found: set \"interface\" in network#wifi of the waybar config by hand" >&2
  fi

  # Lock screen background and rofi preview are normally set when choosing a wallpaper.
  mkdir -p "$HOME/.config/hypr/wallpaper_effects"
  cp "$HOME/Pictures/wallpapers/$DEFAULT_WALLPAPER" "$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"
  ln -sf "$HOME/Pictures/wallpapers/$DEFAULT_WALLPAPER" "$HOME/.config/rofi/.current_wallpaper"
}

install_fonts() {
  local font dir
  for font in JetBrainsMono FantasqueSansMono; do
    dir="$HOME/.local/share/fonts/$font"
    mkdir -p "$dir"
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.tar.xz" | tar -xJ -C "$dir"
  done
  fc-cache -f
}

install_theme() {
  mkdir -p "$HOME/.icons/default"
  curl -fsSL "https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/$CURSOR_THEME.tar.xz" | tar -xJ -C "$HOME/.icons"
  printf '[Icon Theme]\nName=Default\nComment=Default Cursor Theme\nInherits=%s\n' "$CURSOR_THEME" > "$HOME/.icons/default/index.theme"

  mkdir -p "$HOME/.config/gtk-4.0"
  ln -sf "/usr/share/themes/$GTK_THEME/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
  ln -sf "/usr/share/themes/$GTK_THEME/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"

  gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
  gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
  gsettings set org.gnome.desktop.interface cursor-theme default
  gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  gsettings set org.gnome.desktop.default-applications.terminal exec alacritty
}

if [[ "${1:-}" == "--configs-only" ]]; then
  install_files
  adapt_to_machine
else
  install_packages
  install_files
  adapt_to_machine
  install_fonts
  install_theme
  [[ "$SHELL" == */zsh ]] || chsh -s "$(command -v zsh)"
fi

[[ -d "$BACKUP" ]] && echo "Replaced files were saved to $BACKUP"
echo "Done. Log out and choose niri on the login screen."

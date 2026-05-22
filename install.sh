#!/bin/bash
set -e

DOT_DIR="$HOME/.dotfiles"

echo ">>> [1/6] Installing core dependencies..."
sudo pacman -S --needed --noconfirm git stow base-devel

echo ">>> [2/6] Bootstrapping Chaotic-AUR..."
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
sudo cp "$DOT_DIR/system/etc/pacman.conf" /etc/pacman.conf
sudo pacman -Sy

echo ">>> [3/6] Installing Official Packages..."
awk '{print $1}' "$DOT_DIR/lists/explicit.txt" > /tmp/explicit_clean.txt
sudo pacman -S --needed --noconfirm - < /tmp/explicit_clean.txt

echo ">>> [4/6] Bootstrapping yay & Installing AUR Packages..."
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
fi
awk '{print $1}' "$DOT_DIR/lists/aur.txt" > /tmp/aur_clean.txt
yay -S --needed --noconfirm - < /tmp/aur_clean.txt

echo ">>> [5/6] Deploying System Configs..."
sudo cp "$DOT_DIR/system/etc/makepkg.conf" /etc/makepkg.conf
sudo cp "$DOT_DIR/system/etc/environment" /etc/environment

echo ">>> [6/6] Symlinking Dotfiles via Stow..."
cd "$DOT_DIR/home"
stow -t "$HOME" .

echo ">>> DONE. Reboot or start Hyprland."

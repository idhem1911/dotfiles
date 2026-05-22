#!/bin/bash
set -e

DOT_DIR="$HOME/.dotfiles"

echo ">>> [1/3] Extracting package lists..."
pacman -Qqe | grep -v -E '^(base|base-devel)$' > "$DOT_DIR/lists/explicit.txt"
pacman -Qqm > "$DOT_DIR/lists/aur.txt"

echo ">>> [2/3] Syncing /etc configurations..."
sudo cp /etc/pacman.conf "$DOT_DIR/system/etc/"
sudo cp /etc/makepkg.conf "$DOT_DIR/system/etc/"
sudo cp /etc/environment "$DOT_DIR/system/etc/"

echo ">>> [3/3] Committing and pushing..."
cd "$DOT_DIR"
git add .

if git diff --staged --quiet; then
    echo ">>> No changes detected. Repo is clean."
    exit 0
fi

git commit -m "sync: state update $(date +'%Y-%m-%d %H:%M')"
git push origin main
echo ">>> Done. Pushed to GitHub."

#!/usr/bin/env bash

OUT="$HOME/sysConfigs_dump.txt"
>"$OUT"

# Helper: Dump file (resolves symlinks)
dump_file() {
  [[ -f "$1" ]] || return
  local p=$(realpath "$1")
  printf '\n# ==========================================================\n' >>"$OUT"
  printf '#  %s\n' "$p" >>"$OUT"
  printf '# ==========================================================\n\n' >>"$OUT"
  cat "$1" >>"$OUT"
}

# Helper: Dump command with 5s timeout
dump_cmd() {
  echo "⏳ Running: $1"
  printf '\n# ==========================================================\n' >>"$OUT"
  printf '#  CMD: %s\n' "$1" >>"$OUT"
  printf '# ==========================================================\n\n' >>"$OUT"

  # Timeout 5s. Capture stderr (2>&1) to log errors instead of hiding them.
  if ! timeout 5 bash -c "$1" >>"$OUT" 2>&1; then
    echo "⚠️  TIMEOUT/ERROR: Command failed or took >5s." >>"$OUT"
    echo "❌ FAILED/TIMEOUT: $1"
  fi
}

echo "🚀 Starting dump to $OUT..."

# ── Hyprland ──
dump_file ~/.config/hypr/hyprland.conf
dump_file ~/.config/hypr/hypridle.conf
dump_file ~/.config/hypr/hyprpaper.conf
dump_file ~/.config/hypr/hyprlock.conf
dump_file ~/.config/hypr/keybindings.conf

# ── Waybar ──
dump_file ~/.config/waybar/config
dump_file ~/.config/waybar/style.css
dump_file ~/.config/waybar/scripts/amd-gpu.sh
dump_file ~/.config/waybar/scripts/gpu-usage.sh

# ── Core Configs ──
dump_file /etc/makepkg.conf
dump_file /etc/pacman.conf
dump_file ~/.zshrc
dump_file /etc/locale.gen
dump_file /etc/environment

# ── System State ──
dump_cmd "fastfetch"
dump_cmd "uname -a"
dump_cmd "lspci"
dump_cmd "lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT"
dump_cmd "free -h"
dump_cmd "cat /proc/cpuinfo"
dump_cmd "journalctl -b -p err --no-pager"

# ── Packages ──
dump_cmd "pacman -Qe"
dump_cmd "pacman -Qn"
dump_cmd "pacman -Qm"
dump_cmd "pacman -Qg"

# ── GPU / Display ──
dump_cmd "glxinfo -B"
dump_cmd "xrandr"

# ── Services ──
dump_cmd "systemctl list-unit-files --state=enabled --no-pager"
dump_cmd "systemctl --user list-unit-files --state=enabled --no-pager"

echo "✅ Done: $OUT ($(du -h "$OUT" | cut -f1))"

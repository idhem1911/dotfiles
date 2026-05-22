#!/usr/bin/env zsh

WALL_DIR="/home/idhem/Pictures/Wallpapers"
TARGET="$1"

# 1. Detect file (Prioritize GIF for live, fallback to static)
if [[ -f "$WALL_DIR/$TARGET.gif" ]]; then
    FILE="$WALL_DIR/$TARGET.gif"
elif [[ -f "$WALL_DIR/$TARGET.png" ]]; then
    FILE="$WALL_DIR/$TARGET.png"
elif [[ -f "$WALL_DIR/$TARGET.jpg" ]]; then
    FILE="$WALL_DIR/$TARGET.jpg"
else
    echo "File not found: $TARGET"
    exit 1
fi

# 2. Ensure daemon is running
if ! pgrep -x "awww-daemon" > /dev/null; then
    awww-daemon &
    sleep 0.5
fi

# 3. Apply wallpaper (awww natively loops GIFs)
awww img "$FILE" --transition-type grow --transition-pos 1500,200 --transition-duration 2.2 --transition-fps 180

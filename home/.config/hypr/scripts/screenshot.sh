#!/usr/bin/env bash

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

case "$1" in
    area)
        grim -g "$(slurp)" "$FILE"
        ;;
    window)
        GEOM=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
        grim -g "$GEOM" "$FILE"
        ;;
    screen)
        grim "$FILE"
        ;;
esac

if [ -f "$FILE" ]; then
    # Explicitly copy as image/png for chat apps (Discord, Telegram, Browser)
    wl-copy --type image/png < "$FILE"
    
    # THUNAR LIMITATION: Wayland clipboard only holds ONE mime type at a time.
    # If you want to Ctrl+V directly into Thunar as a file, uncomment the line below.
    # WARNING: Doing this will break pasting the image into Telegram/Discord (it will paste the text path instead).
    # wl-copy --type text/uri-list "file://$FILE"
    
    notify-send "Screenshot Saved" "$FILE" -i "$FILE"
fi

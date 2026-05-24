#!/bin/bash
CACHE_DIR="$HOME/.cache"
BUS_FILE="$CACHE_DIR/waybar_brightness_bus"
LOCK_FILE="$CACHE_DIR/waybar_brightness.lock"

mkdir -p "$CACHE_DIR"

# 1. Cache the I2C Bus (Prevents the 3-second hardware scan on every tick)
if [ ! -f "$BUS_FILE" ]; then
    BUS=$(ddcutil detect 2>/dev/null | grep -oP '/dev/i2c-\K\d+' | head -n 1)
    echo "$BUS" > "$BUS_FILE"
else
    BUS=$(cat "$BUS_FILE")
fi

if [ -z "$BUS" ]; then
    echo "󰃠 N/A"
    exit 0
fi

# 2. Mutex Lock (Prevents I2C bus saturation and system freezes)
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    # Another instance is currently adjusting brightness. Drop this scroll tick.
    exit 0
fi

# 3. Handle Inputs
if [ "$1" == "up" ]; then
    ddcutil --bus "$BUS" setvcp 10 + 5 2>/dev/null
elif [ "$1" == "down" ]; then
    ddcutil --bus "$BUS" setvcp 10 - 5 2>/dev/null
else
    # Polling for text output (Waybar interval)
    val=$(ddcutil --bus "$BUS" getvcp 10 2>/dev/null | grep -oP 'current value =\s*\K\d+')
    if [ -n "$val" ]; then
        echo "󰃠 ${val}%"
    else
        echo "󰃠 N/A"
    fi
fi

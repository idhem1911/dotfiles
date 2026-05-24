#!/bin/bash
# Dynamically find the I2C bus for the external monitor
BUS=$(ddcutil detect 2>/dev/null | grep -oP '/dev/i2c-\K\d+' | head -n 1)

if [ -z "$BUS" ]; then
    echo "󰃠 N/A"
    exit 0
fi

if [ "$1" == "up" ]; then
    ddcutil --bus $BUS setvcp 10 + 5
elif [ "$1" == "down" ]; then
    ddcutil --bus $BUS setvcp 10 - 5
else
    val=$(ddcutil --bus $BUS getvcp 10 | grep -oP 'current value =\s*\K\d+')
    echo "󰃠 ${val}%"
fi

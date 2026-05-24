#!/bin/bash
BUS=7
if [ "$1" == "up" ]; then
    ddcutil --bus $BUS setvcp 10 + 5
elif [ "$1" == "down" ]; then
    ddcutil --bus $BUS setvcp 10 - 5
else
    val=$(ddcutil --bus $BUS getvcp 10 | grep -oP 'current value =\s*\K\d+')
    echo "󰃠 ${val}%"
fi

#!/bin/bash
# [FIX] Use wildcard to find the correct AMD GPU path dynamically
gpu_usage=$(cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -n 1)

if [ -z "$gpu_usage" ]; then
    echo "󰢮 G :N/A%"
else
    echo "󰢮 G ${gpu_usage}%"
fi

#!/bin/bash
# [OPTION] Temperature Script (GPU & CPU)
# Get AMD GPU Temp (hides I/O errors)
gpu_temp=$(sensors 2>/dev/null | grep -i "edge" | awk '{print $2}')

# Get CPU Temp (Looks for 'Tctl' or 'Package id 0')
cpu_temp=$(sensors 2>/dev/null | grep -i "Tctl" | awk '{print $2}')
if [ -z "$cpu_temp" ]; then
    cpu_temp=$(sensors 2>/dev/null | grep -i "Package id 0" | awk '{print $2}')
fi

# [OPTION] Output format
if [ -n "$gpu_temp" ]; then
    echo " G${gpu_temp}  C${cpu_temp}"
else
    echo " G: N/A  C${cpu_temp}"
fi

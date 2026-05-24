#!/bin/bash
STATE_FILE="$HOME/.cache/waybar_warmth"
SHADER_FILE="$HOME/.config/hypr/shaders/warmth.glsl"
MIN_TEMP=1500
MAX_TEMP=6500
STEP=500

mkdir -p "$(dirname "$SHADER_FILE")"
[ ! -f "$STATE_FILE" ] && echo 6500 > "$STATE_FILE"
CURRENT_TEMP=$(cat "$STATE_FILE")

if [ "$1" == "up" ]; then
    NEW_TEMP=$((CURRENT_TEMP + STEP))
    [ "$NEW_TEMP" -gt "$MAX_TEMP" ] && NEW_TEMP=$MAX_TEMP
elif [ "$1" == "down" ]; then
    NEW_TEMP=$((CURRENT_TEMP - STEP))
    [ "$NEW_TEMP" -lt "$MIN_TEMP" ] && NEW_TEMP=$MIN_TEMP
elif [ "$1" == "reset" ]; then
    NEW_TEMP=6500
else
    if [ "$CURRENT_TEMP" -ge 6000 ]; then
        echo "󰹜 ${CURRENT_TEMP}K"
    elif [ "$CURRENT_TEMP" -ge 4000 ]; then
        echo "󰹙 ${CURRENT_TEMP}K"
    else
        echo "󱩎 ${CURRENT_TEMP}K"
    fi
    exit 0
fi

echo "$NEW_TEMP" > "$STATE_FILE"

# Reset to neutral if maxed out
if [ "$NEW_TEMP" -ge 6500 ]; then
    hyprctl keyword decoration:screen_shader "" > /dev/null 2>&1
    exit 0
fi

# Calculate RGB multipliers (Float math via awk)
BLUE_MULT=$(awk "BEGIN {print ($NEW_TEMP - 1000) / 5500}")
GREEN_MULT=$(awk "BEGIN {print 1.0 - (1.0 - $BLUE_MULT) * 0.4}")

# Generate the GLSL ES 3.20 Shader
cat << EOF > "$SHADER_FILE"
#version 320 es
precision highp float;
in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture(tex, v_texcoord);
    pixColor.rgb *= vec3(1.0, $GREEN_MULT, $BLUE_MULT);
    fragColor = pixColor;
}
EOF

# Inject into Hyprland
hyprctl keyword decoration:screen_shader "$SHADER_FILE" > /dev/null 2>&1

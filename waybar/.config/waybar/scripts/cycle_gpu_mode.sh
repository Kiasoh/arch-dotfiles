#!/bin/bash
# cycle_gpu_mode.sh

STATE_FILE="$HOME/.config/waybar/.gpu_mode_state"

CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "performance")

case "$CURRENT" in
    performance)
        next="battery"
        ;;
    normal)
        next="performance"
        ;;
    battery)
        next="normal"
        ;;
esac

echo "$next" > "$STATE_FILE"

~/.config/waybar/scripts/gpu_mode_${next}.sh


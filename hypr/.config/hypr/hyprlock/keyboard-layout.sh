#!/bin/bash
layout=$(hyprctl devices -j | jq -r '.keyboards[]?.active_keymap' 2>/dev/null | tail -1)

if [[ "$layout" == *"us"* ]]; then
    echo "US"
elif [[ "$layout" == *"ir"* ]]; then
    echo "IR"
else
    echo "$layout"
fi

#!/bin/bash
# Keep Hyprland's typed values, including all four sides of CSS gap values.
set -euo pipefail
options=(animations:enabled decoration:blur:enabled decoration:shadow:enabled
         general:gaps_in general:gaps_out misc:vrr)
values=()
for option in "${options[@]}"; do
    values+=("$(hyprctl -j getoption "$option")")
done
printf '%s\n' "${values[@]}" | jq -ce -s \
    'map({key: .option, value: (if has("bool") then .bool elif has("int") then .int else .css end)}) | from_entries'

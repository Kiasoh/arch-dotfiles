#!/bin/bash
# Emit current Hyprland visual state as pipe-separated values:
# anim|blur|shadow|rounding|border|gaps_in|vrr
o1="$(hyprctl getoption -j animations:enabled 2>/dev/null)"
o2="$(hyprctl getoption -j decoration:blur:enabled 2>/dev/null)"
o3="$(hyprctl getoption -j decoration:shadow:enabled 2>/dev/null)"
o4="$(hyprctl getoption -j decoration:rounding 2>/dev/null)"
o5="$(hyprctl getoption -j general:border_size 2>/dev/null)"
o6="$(hyprctl getoption -j general:gaps_in 2>/dev/null)"
o7="$(hyprctl getoption -j misc:vrr 2>/dev/null)"

b() { echo "$1" | grep -q '"bool": true' && echo 1 || echo 0; }
i() {
    local v="$(echo "$1" | grep -o '"int": [0-9]*' | awk '{print $2}')"
    [ -z "$v" ] && v="$(echo "$1" | sed -n 's/.*"css": "\([0-9]*\) .*/\1/p')"
    [ -z "$v" ] && v="$(echo "$1" | sed -n 's/.*"css": "\([0-9]*\)"/\1/p')"
    echo "$v"
}

echo "$(b "$o1")|$(b "$o2")|$(b "$o3")|$(i "$o4")|$(i "$o5")|$(i "$o6")|$(i "$o7")"

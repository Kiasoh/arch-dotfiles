#!/bin/bash
# Emit "|h hz hz" style: "144|144 60" for eDP-1 (current Hz first, then available).
out="$(hyprctl monitors 2>/dev/null)"
modes="$(echo "$out" | awk '/availableModes:/{for(i=2;i<=NF;i++) print $i}' \
    | sed -n 's/.*@\([0-9]*\)\..*Hz/\1/p' | sort -rn | awk '{printf "%s ", $1}' | sed 's/ $//')"
cur="$(echo "$out" | awk '/^Monitor eDP-1/{f=1} f && /@/{print $1; exit}' \
    | sed -n 's/.*@\([0-9]*\)\..*/\1/p')"
# fall back to first mode when the parser could not get the current line
[ -z "$cur" ] && cur="$(echo "$modes" | awk '{print $1}')"
echo "${cur}|${modes}"

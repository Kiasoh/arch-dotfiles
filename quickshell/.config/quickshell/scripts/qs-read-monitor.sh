#!/bin/bash
# Return the complete monitor object, preserving layout and fractional refresh rates.
set -euo pipefail
hyprctl -j monitors | jq -ce --arg name "${1:?monitor name required}" \
    '.[] | select(.name == $name)'

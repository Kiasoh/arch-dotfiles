#!/bin/bash
# Set CPU scaling governor on every core. Run via pkexec (root).
# Usage: qs-cpu-governor.sh <governor>
set -e

GOV="$1"
AVAIL="$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors 2>/dev/null)"

if [ -z "$GOV" ]; then
    echo "usage: qs-cpu-governor.sh <governor>" >&2
    exit 1
fi
if ! echo "$AVAIL" | grep -qw "$GOV"; then
    echo "governor not available: $GOV (have: $AVAIL)" >&2
    exit 1
fi

for gov in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    [ -f "$gov" ] && echo "$GOV" > "$gov"
done

#!/bin/bash
# Set Intel EPP on every core. Run via pkexec (root).
# Usage: qs-cpu-epp.sh <performance|balance_performance|power|...>
set -e

EPP="$1"
BASE=/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference
AVAIL="$(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences 2>/dev/null)"

if [ -z "$EPP" ]; then
    echo "usage: qs-cpu-epp.sh <epp-value>" >&2
    exit 1
fi
if [ ! -f "$BASE" ]; then
    echo "no EPP support on this system" >&2
    exit 1
fi
if [ -n "$AVAIL" ] && ! echo "$AVAIL" | grep -qw "$EPP"; then
    echo "EPP not available: $EPP (have: $AVAIL)" >&2
    exit 1
fi

for epp in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    [ -f "$epp" ] && echo "$EPP" > "$epp"
done

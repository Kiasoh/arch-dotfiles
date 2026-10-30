#!/bin/bash
# Set envycontrol GPU mode. Run via pkexec (root).
# Usage: qs-gpu-mode.sh <nvidia|hybrid|integrated>
set -e

case "$1" in
    nvidia|hybrid|integrated)
        envycontrol -s "$1"
        ;;
    *)
        echo "usage: qs-gpu-mode.sh <nvidia|hybrid|integrated>" >&2
        exit 1
        ;;
esac

# wait for the query to reflect the new mode, so the panel can read it back
for _ in $(seq 1 20); do
    [ "$(envycontrol --query 2>/dev/null)" = "$1" ] && exit 0
    sleep 0.2
done
echo "warning: query did not confirm new mode" >&2
exit 0

#!/bin/bash
# One-shot TLP profile override. Run via pkexec (root).
# Usage: qs-tlp-force.sh <ac|bat>
# Note: TLP's daemon re-derives its profile on AC events, so this is an override,
# not a persistent state (which is why the panel shows no read-back for it).
set -e

case "$1" in
    ac) tlp ac ;;
    bat) tlp bat ;;
    *)
        echo "usage: qs-tlp-force.sh <ac|bat>" >&2
        exit 1
        ;;
esac

#!/usr/bin/env bash
set -euo pipefail

profile=${1:-}
case "$profile" in
    Quiet|Balanced|Performance) ;;
    *) echo 'Invalid ASUS profile.' >&2; exit 1 ;;
esac

asusctl profile set "$profile"
state=$(asusctl profile get)
if [[ ! $state =~ (^|$'\n')Active\ profile:\ *${profile}($|$'\n') ]]; then
    echo "ASUS did not activate $profile. Another power policy may have overridden it." >&2
    exit 1
fi

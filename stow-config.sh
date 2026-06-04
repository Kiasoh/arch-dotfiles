#!/usr/bin/env bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <package>"
    exit 1
fi

PACKAGE="$1"
DOTFILES_DIR="$HOME/my-dotfiles"
CONFIG_DIR="$HOME/.config/$PACKAGE"

cd "$DOTFILES_DIR"

mkdir -p "$PACKAGE/.config"

if [ -d "$CONFIG_DIR" ] && [ ! -L "$CONFIG_DIR" ]; then
    mv "$CONFIG_DIR" "$PACKAGE/.config/"
fi

stow "$PACKAGE"

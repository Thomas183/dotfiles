#!/usr/bin/env bash
SCRIPTS_DIR="$HOME/.config/rofi/scripts/bin"
if [ -z "$1" ]; then
    ls "$SCRIPTS_DIR" 2>/dev/null
else
    exec "$SCRIPTS_DIR/$1"
fi

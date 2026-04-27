#!/usr/bin/env bash
# Watches colors.sh and calls apply-theme.sh on every save.
# Started automatically by Hyprland via autostart.conf.

DOTS="$HOME/dotfiles/homeconf/laptop"

stdbuf -oL inotifywait -m -e close_write,moved_to "$DOTS" |
while read -r _ _ file; do
    [ "$file" = "colors.sh" ] && "$DOTS/apply-theme.sh"
done

#!/bin/bash

LAYOUT="$1"
WAYBAR_DIR="$HOME/.config/waybar"
STATE_FILE="$WAYBAR_DIR/scripts/current-layout"

if [ -z "$LAYOUT" ]; then
    echo "Usage: $0 <layout-name>"
    exit 1
fi

if [ ! -d "$WAYBAR_DIR/layouts/$LAYOUT" ]; then
    notify-send "Waybar" "Layout '$LAYOUT' not found" -u critical
    exit 1
fi

# Save state
echo "$LAYOUT" > "$STATE_FILE"

# Swap symlinks
ln -sf "$WAYBAR_DIR/layouts/$LAYOUT/config.jsonc" "$WAYBAR_DIR/config.jsonc"
ln -sf "$WAYBAR_DIR/layouts/$LAYOUT/style.css"    "$WAYBAR_DIR/style.css"

# Restart waybar
pkill waybar > /dev/null 2>&1
sleep 0.5
waybar &> /dev/null & disown

notify-send "Waybar" "Layout switched to: $LAYOUT" -t 2000

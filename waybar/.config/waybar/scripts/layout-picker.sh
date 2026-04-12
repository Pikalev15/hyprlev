#!/bin/bash

WAYBAR_DIR="$HOME/.config/waybar"
SWITCH_SCRIPT="$WAYBAR_DIR/scripts/switch-layout.sh"

# List only non-hidden layout directories
layouts=($(find "$WAYBAR_DIR/layouts" -mindepth 1 -maxdepth 1 -type d ! -iname ".*" -exec basename {} \; | sort))

# Show menu
selected=$(printf '%s\n' "${layouts[@]}" | rofi -dmenu -p "Select Layout" -theme ~/.config/rofi/config.rasi)

# Apply selected layout if not empty
[[ -n "$selected" ]] && "$SWITCH_SCRIPT" "$selected" >/dev/null 2>&1
```

### `switch-layout.sh` — no changes needed

It stays exactly as written before. The picker calls it, so they're separate concerns:
```
layout-picker.sh   →   shows rofi menu   →   calls switch-layout.sh <name>
switch-layout.sh   →   swaps symlinks    →   restarts waybar

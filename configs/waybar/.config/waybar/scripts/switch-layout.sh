#!/bin/bash

LAYOUT="$1"
WAYBAR_DIR="$HOME/.config/waybar"
STATE_FILE="$WAYBAR_DIR/scripts/current-layout"

if [ -z "$LAYOUT" ]; then
  echo "Usage: $0 <layout-name>"
  exit 1
fi

if [ ! -d "$WAYBAR_DIR/layouts/$LAYOUT" ]; then
  notify-send "Layout" "Layout '$LAYOUT' not found" -u critical
  exit 1
fi

# Save state
echo "$LAYOUT" >"$STATE_FILE"

# Kill everything first
pkill waybar >/dev/null 2>&1
pkill quickshell >/dev/null 2>&1
sleep 0.5

AUTOSTART="$HOME/.config/hypr/hyprland/autostart.conf"
sed -i '/exec-once = waybar/d' "$AUTOSTART"
sed -i '/exec-once = quickshell/d' "$AUTOSTART"

case "$LAYOUT" in
catppuccin | Full | Glass | island | Japan | macos | minimal | minimal-2)
  ln -sf "$WAYBAR_DIR/layouts/$LAYOUT/config.jsonc" "$WAYBAR_DIR/config.jsonc"
  ln -sf "$WAYBAR_DIR/layouts/$LAYOUT/style.css" "$WAYBAR_DIR/style.css"
  waybar &>/dev/null &
  disown
  echo "exec-once = waybar" >>"$AUTOSTART"
  ;;
quickshell-bar)
  quickshell -p ~/.config/quickshell/bar &
  disown
  echo "exec-once = quickshell -p ~/.config/quickshell/bar" >>"$AUTOSTART"
  ;;
quickshell-hypr)
  quickshell -p ~/.config/hypr/scripts/quickshell/Main.qml &
  disown
  quickshell -p ~/.config/hypr/scripts/quickshell/TopBar.qml &
  disown
  echo "exec-once = quickshell -p ~/.config/hypr/scripts/quickshell/Main.qml & quickshell -p ~/.config/hypr/scripts/quickshell/TopBar.qml &" >>"$AUTOSTART"
  ;;
quickshell-nandroid)
  quickshell -p ~/.config/quickshell/nandoroid/shell.qml
  disown
  echo "exec-once = quickshell -p ~/.config/quickshell/nandoroid/shell.qml &" >>"$AUTOSTART"
  ;;
*)
  notify-send "Layout" "Unknown layout: $LAYOUT" -u critical
  exit 1
  ;;
esac

notify-send "Layout" "Switched to: $LAYOUT" -t 2000

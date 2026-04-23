#!/bin/bash

declare -A options=(
    ["󰸉  Theme"]="$HOME/.config/themes/rofi-launcher.sh"
    ["  Wallpaper"]="$HOME/.config/themes/wallpaper-selector.sh"
    ["  Waybar Layout"]="$HOME/.config/waybar/scripts/layout-picker.sh"
    ["  Config Browser"]="$HOME/.config/rofi/scripts/config-browser.sh"
    ["  Fonts"]="$HOME/.config/themes/font-switcher.sh"
)

selected=$(printf '%s\n' "${!options[@]}" | sort | rofi -dmenu -i -p "Select Wallpaper" -show-icons -theme ~/.config/rofi/configs/minimal.rasi)

[[ -n "$selected" ]] && bash "${options[$selected]}"

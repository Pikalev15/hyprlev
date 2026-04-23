#!/bin/bash
# Hyprland Keymap Reference Menu

ROFI_CONFIG="$HOME/.config/rofi/configs/main-menu.rasi"

rofi_cmd() {
    if [ -f "$ROFI_CONFIG" ]; then
        rofi -config "$ROFI_CONFIG" "$@"
    else
        rofi "$@"
    fi
}

show_keymaps() {
    cat << EOF
󰍉 SUPER → Rofi launcher
󰖟 SUPER + B → Open browser
󰉋 SUPER + E → File manager (Nautilus)
󰆍 SUPER + T → Terminal
󰉌 SUPER + F → Toggle floating
󰖕 SUPER + Q → Close app
󰐥 XF86Sleep → wlogout
󰌾 XF86Sleep (hold) → Hyprlock
󱂬 SUPER + 1-9 → Switch workspace
󰜸 SUPER + SHIFT + 1-9 → Move to workspace
󰖯 ALT + TAB → Snappy window switcher
󰀻 XF86LaunchA → Hyprexpo overview
󰕾 XF86AudioRaiseVolume → Volume up
󰕿 XF86AudioLowerVolume → Volume down
󰖁 XF86AudioMute → Mute volume
󰃞 XF86MonBrightnessUp → Brightness up
󰃝 XF86MonBrightnessDown → Brightness down
󰒓 SUPER + ALT + R → Reload Hyprland config
󰉋 SUPER + C → Browse configs
󰸉 SUPER + ALT + W → Wallpaper menu (Quickshell)
󰍹 SUPER + M → Monitor menu (Quickshell)
󰽶 SUPER + ALT + S → Toggle hyprsunset
󰔶 SUPER + U → Switch theme
󰸉 SUPER + SHIFT + U → Switch wallpaper
󰖕 SUPER + ALT + U → Switch top bar
EOF
}

show_categories() {
    CATEGORY=$(echo -e "󰍉 All Keybindings\n󱂬 Workspaces\n󰀻 Aesthetics\n󰀻 Applications\n󰕾 Media & Brightness\n󰔶 Quickshell" | rofi_cmd -dmenu -i -p "Keymap Categories")

    case "$CATEGORY" in
        *"All Keybindings")
            show_keymaps | rofi_cmd -dmenu -i -p "Keybindings" -no-custom
            ;;
        *"Workspaces")
            show_keymaps | grep -E "(workspace|float|switcher|overview|Close)" | rofi_cmd -dmenu -i -p "Workspaces" -no-custom
            ;;
        *"Aesthetics")
            show_keymaps | grep -E "(theme|wallpaper|bar|hyprsunset)" | rofi_cmd -dmenu -i -p "Aesthetics" -no-custom
            ;;
        *"Applications")
            show_keymaps | grep -E "(browser|manager|Terminal|Rofi|configs|wlogout|Hyprlock)" | rofi_cmd -dmenu -i -p "Applications" -no-custom
            ;;
        *"Media"*)
            show_keymaps | grep -E "(Volume|Brightness|Mute)" | rofi_cmd -dmenu -i -p "Media & Brightness" -no-custom
            ;;
        *"Quickshell")
            show_keymaps | grep -E "(Quickshell|Wallpaper menu|Monitor menu)" | rofi_cmd -dmenu -i -p "Quickshell" -no-custom
            ;;
    esac
}

show_categories

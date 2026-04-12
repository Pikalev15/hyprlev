#!/usr/bin/env bash

ROFI_THEME="$HOME/.config/rofi/config.rasi"

CONFIG_DIRS=(
    "$HOME/.config/hypr"
    "$HOME/.config/kitty"
    "$HOME/.config/rofi"
    "$HOME/.config/themes"
    "$HOME/.config/waybar"
    "$HOME/.config/wlogout"
    "$HOME/.config/swaync"
    "$HOME/.config/fish"
    "$HOME/.config/nwg-dock-hyprland"
    "$HOME/.config/snappy-switcher"
)

# Step 1: show folder names
LABELS=()
for dir in "${CONFIG_DIRS[@]}"; do
    LABELS+=("$(basename "$dir")")
done

CHOSEN_LABEL=$(printf '%s\n' "${LABELS[@]}" | rofi -dmenu -p " Config" -i -theme "$ROFI_THEME")

[ -z "$CHOSEN_LABEL" ] && exit 0

for dir in "${CONFIG_DIRS[@]}"; do
    if [[ "$(basename "$dir")" == "$CHOSEN_LABEL" ]]; then
        CHOSEN_DIR="$dir"
        break
    fi
done

# Step 2: browse function — shows dirs and files at current level
browse() {
    local current_dir="$1"

    while true; do
        local items=()

        if [[ "$current_dir" != "$CHOSEN_DIR" ]]; then
            items+=("..")
        fi

        # Subdirectories
        while IFS= read -r d; do
            items+=("$(basename "$d")/")
        done < <(find "$current_dir" -mindepth 1 -maxdepth 1 -type d | sort)

        # Files and symlinks
        while IFS= read -r f; do
            items+=("$(basename "$f")")
        done < <(find "$current_dir" -mindepth 1 -maxdepth 1 \( -type f -o -type l \) | sort)

        local prompt=" $(basename "$current_dir")"
        local chosen=$(printf '%s\n' "${items[@]}" | rofi -dmenu -p "$prompt" -i -theme "$ROFI_THEME")

        [ -z "$chosen" ] && exit 0

        if [[ "$chosen" == ".." ]]; then
            current_dir="$(dirname "$current_dir")"
        elif [[ "$chosen" == */ ]]; then
            current_dir="$current_dir/${chosen%/}"
        else
            kitty --class "floating-nvim" nvim "$current_dir/$chosen" &
            exit 0
        fi
    done
}

browse "$CHOSEN_DIR"

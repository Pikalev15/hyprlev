#!/bin/bash
set -e

# ── Colors ──────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'

# ── System Info ─────────────────────────────────────────────────
get_info() {
    USER=$(whoami)
    OS=$(grep "^NAME" /etc/os-release | cut -d= -f2 | tr -d '"')
    CPU=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
    GPU=$(lspci | grep -i vga | cut -d: -f3 | xargs)
}

# ── Header ──────────────────────────────────────────────────────
print_header() {
    clear
    echo -e "${DIM}----------------------------------------------------------------${RESET}"
    echo -e "  ${CYAN}GitHub:${RESET}  https://github.com/Pikalev15/hyprlev"
    echo -e "  ${CYAN}Author:${RESET}  Pikalev15"
    echo -e "${DIM}----------------------------------------------------------------${RESET}"
    echo -e "  ${BOLD}User:${RESET}    $USER"
    echo -e "  ${BOLD}OS:${RESET}      $OS"
    echo -e "  ${BOLD}CPU:${RESET}     $CPU"
    echo -e "  ${BOLD}GPU:${RESET}     $GPU"
    echo -e "${DIM}================================================================${RESET}"
    echo ""
}

# ── Menu State ──────────────────────────────────────────────────
declare -A STATE
STATE[deps]=0
STATE[clone]=0
STATE[backup]=0
STATE[stow]=0

SELECTED=0
ITEMS=5  # number of menu items

# ── Draw Menu ───────────────────────────────────────────────────
draw_menu() {
    print_header
    echo -e "  ${BOLD}Main Menu${RESET}"
    echo -e "  ${DIM}Navigate with ARROWS. Toggle with ENTER. S to start.${RESET}"
    echo -e "  ${DIM}------------------------------------------------${RESET}"
    echo ""

    local items=(
        "Install Dependencies (stow, git)"
        "Clone Dotfiles to ~/hyprlev"
        "Backup existing ~/.config"
        "Stow all config packages"
        "START INSTALLATION"
    )

    for i in "${!items[@]}"; do
        local prefix="  "
        local state_key=""
        case $i in
            0) state_key="deps" ;;
            1) state_key="clone" ;;
            2) state_key="backup" ;;
            3) state_key="stow" ;;
        esac

        # Cursor
        if [ "$i" -eq "$SELECTED" ]; then
            prefix="${GREEN}> ${RESET}"
        fi

        # Toggle state
        if [ "$i" -lt 4 ]; then
            if [ "${STATE[$state_key]}" -eq 1 ]; then
                echo -e "${prefix}${GREEN}[ON]${RESET} ${items[$i]}"
            else
                echo -e "${prefix}${YELLOW}[ ]${RESET} ${DIM}${items[$i]}${RESET}"
            fi
        else
            # START button
            if [ "$i" -eq "$SELECTED" ]; then
                echo -e "${prefix}${BOLD}${GREEN}${items[$i]}${RESET}"
            else
                echo -e "${prefix}${BOLD}${items[$i]}${RESET}"
            fi
        fi
    done
    echo ""
}

# ── Arrow Key Input ─────────────────────────────────────────────
read_key() {
    IFS= read -rsn1 key
    if [[ $key == $'\x1b' ]]; then
        read -rsn2 key
        case $key in
            '[A') echo "UP" ;;
            '[B') echo "DOWN" ;;
        esac
    elif [[ $key == "" ]]; then
        echo "ENTER"
    elif [[ $key == "s" || $key == "S" ]]; then
        echo "START"
    elif [[ $key == "q" || $key == "Q" ]]; then
        echo "QUIT"
    fi
}

# ── Run Steps ───────────────────────────────────────────────────
run_install() {
    clear
    echo -e "${BOLD}${GREEN}Starting installation...${RESET}\n"

    if [ "${STATE[deps]}" -eq 1 ]; then
        echo -e "${CYAN}==> Installing dependencies...${RESET}"
        sudo pacman -S --needed stow git
    fi

    if [ "${STATE[clone]}" -eq 1 ]; then
        echo -e "${CYAN}==> Cloning dotfiles...${RESET}"
        if [ -d "$HOME/hyprlev" ]; then
            echo "~/hyprlev exists, pulling latest..."
            git -C "$HOME/hyprlev" pull
        else
            git clone https://github.com/Pikalev15/hyprlev.git "$HOME/hyprlev"
        fi
    fi

    if [ "${STATE[backup]}" -eq 1 ]; then
        echo -e "${CYAN}==> Backing up ~/.config...${RESET}"
        mkdir -p "$HOME/.config.bak"
        for dir in ags btop cava drift fish gtk-3.0 gtk-4.0 hypr kitty \
                    nwg-dock-hyprland nwg-look quickshell rofi snappy-switcher \
                    swaync themes waybar wlogout; do
            if [ -d "$HOME/.config/$dir" ] && [ ! -L "$HOME/.config/$dir" ]; then
                cp -r "$HOME/.config/$dir" "$HOME/.config.bak/"
                echo "  Backed up $dir"
            fi
        done
    fi

    if [ "${STATE[stow]}" -eq 1 ]; then
        echo -e "${CYAN}==> Stowing configs...${RESET}"
        cd "$HOME/hyprlev/configs"
        for dir in */; do
            stow --target="$HOME" "$dir" 2>/dev/null && \
                echo -e "  ${GREEN}Stowed${RESET} ${dir%/}" || \
                echo -e "  ${YELLOW}Skipped${RESET} ${dir%/} (conflict)"
        done
    fi

    # Ping hit counter
    curl -s "https://hits.sh/github.com/Pikalev15/hyprlev" > /dev/null 2>&1 &

    echo -e "\n${BOLD}${GREEN}Done!${RESET} Restart or launch Hyprland to apply."
}

# ── Main Loop ───────────────────────────────────────────────────
get_info

while true; do
    draw_menu
    key=$(read_key)

    case $key in
        UP)
            ((SELECTED--))
            [ "$SELECTED" -lt 0 ] && SELECTED=$((ITEMS - 1))
            ;;
        DOWN)
            ((SELECTED++))
            [ "$SELECTED" -ge "$ITEMS" ] && SELECTED=0
            ;;
        ENTER|START)
            if [ "$SELECTED" -eq 4 ]; then
                run_install
                break
            else
                case $SELECTED in
                    0) [ "${STATE[deps]}" -eq 1 ] && STATE[deps]=0 || STATE[deps]=1 ;;
                    1) [ "${STATE[clone]}" -eq 1 ] && STATE[clone]=0 || STATE[clone]=1 ;;
                    2) [ "${STATE[backup]}" -eq 1 ] && STATE[backup]=0 || STATE[backup]=1 ;;
                    3) [ "${STATE[stow]}" -eq 1 ] && STATE[stow]=0 || STATE[stow]=1 ;;
                esac
            fi
            ;;
        QUIT)
            echo "Exiting."
            exit 0
            ;;
    esac
done

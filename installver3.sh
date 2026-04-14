#!/usr/bin/env bash

# ==============================================================================
# Script Versioning & Initialization
# ==============================================================================
DOTS_VERSION="1.0.0"
VERSION_FILE="$HOME/.local/state/hyprlev-version"

setterm -blank 0 -powerdown 0 2>/dev/null || true
printf '\033[9;0]' 2>/dev/null || true

# Global State
FAILED_PKGS=()

KB_LAYOUTS="us"
KB_LAYOUTS_DISPLAY="English (US)"
KB_OPTIONS="grp:alt_shift_toggle"

VISITED_KEYBOARD=false

mkdir -p "$(dirname "$VERSION_FILE")"

if [ -f "$VERSION_FILE" ]; then
    source "$VERSION_FILE"
    if [ -n "$LOCAL_VERSION" ]; then
        [ -n "$KB_LAYOUTS" ] && VISITED_KEYBOARD=true
    fi
else
    LOCAL_VERSION="Not Installed"
fi

# ==============================================================================
# Colors
# ==============================================================================
RESET="\e[0m"; BOLD="\e[1m"; DIM="\e[2m"
C_BLUE="\e[34m"; C_CYAN="\e[36m"; C_GREEN="\e[32m"
C_YELLOW="\e[33m"; C_RED="\e[31m"; C_MAGENTA="\e[35m"

# ==============================================================================
# Packages
# ==============================================================================
PKGS=(
    "hyprland" "hyprlock" "hyprpaper" "hypridle" "hyprpicker"
    "kitty" "rofi-wayland" "swaync" "waybar" "wlogout"
    "pipewire" "wireplumber" "pipewire-pulse" "pipewire-alsa" "pipewire-jack"
    "pavucontrol" "pamixer" "brightnessctl" "playerctl"
    "swayosd-git" "cava" "btop" "fastfetch"
    "wl-clipboard" "cliphist" "grim" "slurp" "satty"
    "nwg-dock-hyprland" "nwg-look" "quickshell-git"
    "networkmanager" "network-manager-applet"
    "bluez" "bluez-utils" "libnotify"
    "jq" "socat" "inotify-tools" "imagemagick" "wget" "git" "stow"
    "ttf-jetbrains-mono-nerd" "power-profiles-daemon"
    "xdg-desktop-portal-hyprland" "xdg-desktop-portal-gtk"
    "qt6-wayland" "qt5-wayland" "python"
)

# ==============================================================================
# OS Detection & AUR Helper
# ==============================================================================
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo -e "${C_RED}Cannot detect OS.${RESET}"; exit 1
fi

case $OS in
    arch|endeavouros|manjaro|cachyos)
        if ! command -v fzf &>/dev/null || ! command -v lspci &>/dev/null || ! command -v curl &>/dev/null; then
            echo -e "${C_CYAN}Bootstrapping TUI dependencies...${RESET}"
            sudo pacman -Sy --noconfirm --needed fzf pciutils curl >/dev/null 2>&1
        fi

        if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
            echo -e "${C_CYAN}Installing yay (AUR helper)...${RESET}"
            sudo pacman -S --noconfirm --needed base-devel git
            git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin >/dev/null 2>&1
            (cd /tmp/yay-bin && makepkg -si --noconfirm >/dev/null 2>&1)
            rm -rf /tmp/yay-bin
        fi

        if command -v yay &>/dev/null; then PKG_MANAGER="yay -S --noconfirm --needed"
        elif command -v paru &>/dev/null; then PKG_MANAGER="paru -S --noconfirm --needed"
        else PKG_MANAGER="sudo pacman -S --noconfirm --needed"; fi
        ;;
    *)
        echo -e "${C_RED}Unsupported OS ($OS). Arch-based distros only.${RESET}"; exit 1 ;;
esac

# ==============================================================================
# Hardware Info
# ==============================================================================
USER_NAME=$USER
OS_NAME=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
CPU_INFO=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
GPU_INFO=$(lspci -nn | grep -iE 'vga|3d|display' | cut -d: -f3 | sed -E 's/ \(rev [0-9a-f]+\)//g' | xargs)
[[ -z "$GPU_INFO" ]] && GPU_INFO="Unknown"

# ==============================================================================
# Header
# ==============================================================================
draw_header() {
    printf "\033[H"
    printf "${BOLD}${C_CYAN}"
    cat << "EOF"
 ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗     ███████╗██╗   ██╗
 ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔════╝██║   ██║
 ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     █████╗  ██║   ██║
 ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══╝  ╚██╗ ██╔╝
 ██║  ██║   ██║   ██║     ██║  ██║███████╗███████╗ ╚████╔╝
 ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝  ╚═══╝
EOF
    printf "${RESET}\n"
    printf "\033[K${C_BLUE} -----------------------------------------------------------------${RESET}\n"
    printf "\033[K${BOLD}${C_GREEN} GitHub:${RESET}  https://github.com/Pikalev15/hyprlev\n"
    printf "\033[K${BOLD}${C_CYAN} Author:${RESET}  Pikalev15\n"
    printf "\033[K${C_BLUE} -----------------------------------------------------------------${RESET}\n"
    printf "\033[K${BOLD} User:           ${RESET} %s\n" "$USER_NAME"
    printf "\033[K${BOLD} OS:             ${RESET} %s\n" "$OS_NAME"
    printf "\033[K${BOLD} CPU:            ${RESET} %s\n" "$CPU_INFO"
    printf "\033[K${BOLD} GPU:            ${RESET} %s\n" "$GPU_INFO"
    printf "\033[K${C_BLUE} -----------------------------------------------------------------${RESET}\n"
    printf "\033[K${BOLD} Server Version: ${RESET} %s\n" "$DOTS_VERSION"
    printf "\033[K${BOLD} Local Version:  ${RESET} %s\n" "$LOCAL_VERSION"
    printf "\033[K${C_BLUE} =================================================================${RESET}\n\n"
    printf "\033[J"
}

# ==============================================================================
# Keyboard Setup
# ==============================================================================
manage_keyboard() {
    local available_layouts=(
        "us - English (US)" "gb - English (UK)" "au - English (Australia)"
        "ca - English/French (Canada)" "ie - English (Ireland)"
        "fr - French" "be - Belgian" "ch - Swiss"
        "de - German" "at - Austrian" "nl - Dutch"
        "es - Spanish" "pt - Portuguese" "br - Portuguese (Brazil)"
        "it - Italian" "gr - Greek"
        "se - Swedish" "no - Norwegian" "dk - Danish"
        "fi - Finnish" "is - Icelandic"
        "pl - Polish" "cz - Czech" "sk - Slovak" "hu - Hungarian"
        "ro - Romanian" "bg - Bulgarian" "ru - Russian" "ua - Ukrainian"
        "rs - Serbian" "hr - Croatian" "si - Slovenian"
        "lt - Lithuanian" "lv - Latvian" "ee - Estonian"
        "il - Hebrew" "ara - Arabic" "ir - Persian (Farsi)"
        "in - Indian" "th - Thai" "vn - Vietnamese"
        "cn - Chinese" "jp - Japanese" "kr - Korean"
        "latam - Spanish (Latin America)"
    )
    local selected_codes=()
    local selected_names=()

    while true; do
        draw_header
        echo -e "${BOLD}${C_CYAN}=== Keyboard Layout Configuration ===${RESET}\n"

        [ ${#selected_codes[@]} -gt 0 ] && \
            echo -e "Currently added: ${C_GREEN}$(IFS=', '; echo "${selected_names[*]}")${RESET}\n"

        local choice
        choice=$(printf "%s\n" "Done (Finish Selection)" "${available_layouts[@]}" | fzf \
            --layout=reverse --border=rounded --margin=1,2 --height=20 \
            --prompt=" Add Layout > " --pointer=">" \
            --header=" Select a language to add, or select Done ")

        if [[ -z "$choice" || "$choice" == *"Done"* ]]; then
            [ ${#selected_codes[@]} -eq 0 ] && selected_codes=("us") && selected_names=("English (US)")
            break
        fi

        local code=$(echo "$choice" | awk '{print $1}')
        local name=$(echo "$choice" | cut -d'-' -f2- | sed 's/^ //')
        selected_codes+=("$code")
        selected_names+=("$name")
    done

    draw_header
    echo -e "${BOLD}${C_CYAN}=== Key Combination to Switch Layouts ===${RESET}\n"
    echo -e "Currently added: ${C_GREEN}$(IFS=', '; echo "${selected_names[*]}")${RESET}\n"

    local choice
    choice=$(echo -e \
        "1. Alt + Shift (grp:alt_shift_toggle)\n2. Win + Space (grp:win_space_toggle)\n3. Caps Lock (grp:caps_toggle)\n4. Ctrl + Shift (grp:ctrl_shift_toggle)\n5. Ctrl + Alt (grp:ctrl_alt_toggle)\n6. Right Alt (grp:toggle)\n7. No Toggle (Single Layout)" | fzf \
        --ansi --layout=reverse --border=rounded --margin=1,2 --height=15 \
        --prompt=" Toggle Keybind > " --pointer=">" \
        --header=" Select layout switching method ")

    local kb_opt=""
    case "$choice" in
        *"1"*) kb_opt="grp:alt_shift_toggle" ;;
        *"2"*) kb_opt="grp:win_space_toggle" ;;
        *"3"*) kb_opt="grp:caps_toggle" ;;
        *"4"*) kb_opt="grp:ctrl_shift_toggle" ;;
        *"5"*) kb_opt="grp:ctrl_alt_toggle" ;;
        *"6"*) kb_opt="grp:toggle" ;;
        *"7"*) kb_opt="" ;;
        *) kb_opt="grp:alt_shift_toggle" ;;
    esac

    KB_LAYOUTS=$(IFS=','; echo "${selected_codes[*]}")
    KB_LAYOUTS_DISPLAY=$(IFS=', '; echo "${selected_names[*]}")
    KB_OPTIONS="$kb_opt"

    echo -e "\n${C_GREEN}Keyboard configured: $KB_LAYOUTS_DISPLAY | Switch = ${KB_OPTIONS:-None}${RESET}"
    sleep 1.5
    VISITED_KEYBOARD=true
}

# ==============================================================================
# Package Manager
# ==============================================================================
manage_packages() {
    while true; do
        draw_header
        local action
        action=$(echo -e "1. View Packages to be Installed\n2. Add Custom Packages\n3. Back to Main Menu" | fzf \
            --layout=reverse --border=rounded --margin=1,2 --height=12 \
            --prompt=" Package Manager > " --pointer=">" \
            --header=" Use ARROW KEYS and ENTER ")

        case "$action" in
            *"1"*)
                echo "${PKGS[@]}" | tr ' ' '\n' | fzf \
                    --layout=reverse --border=rounded --margin=1,2 --height=25 \
                    --prompt=" Packages > " --pointer=">" \
                    --header=" Press ESC to return "
                ;;
            *"2"*)
                echo -e "${C_CYAN}Enter package names separated by spaces (empty to cancel):${RESET}"
                read -r new_pkgs
                if [ -n "$new_pkgs" ]; then
                    PKGS+=($new_pkgs)
                    echo -e "${C_GREEN}Added!${RESET}"; sleep 1
                fi
                ;;
            *) break ;;
        esac
    done
}

# ==============================================================================
# Overview & Keybinds
# ==============================================================================
show_overview() {
    clear; draw_header
    echo -e "${BOLD}${C_MAGENTA}=== Hyprlev Overview & Keybinds ===${RESET}\n"

    print_kb() { printf "  ${C_CYAN}[${RESET} ${BOLD}%-20s${RESET} ${C_CYAN}]${RESET}  ${C_YELLOW}➜${RESET}  %s\n" "$1" "$2"; }

    echo -e "${BOLD}${C_BLUE}--- Applications ---${RESET}"
    print_kb "SUPER + RETURN" "Terminal (kitty)"
    print_kb "SUPER + D" "App Launcher (rofi)"
    print_kb "SUPER + C" "Config Browser"
    print_kb "SUPER + L" "Lock Screen"
    echo ""

    echo -e "${BOLD}${C_BLUE}--- Theme Switching ---${RESET}"
    print_kb "SUPER + SHIFT + W" "Wallpaper / Theme Picker"
    echo ""

    echo -e "${BOLD}${C_BLUE}--- Window Management ---${RESET}"
    print_kb "SUPER + Q" "Close Window"
    print_kb "SUPER + SHIFT + F" "Toggle Floating"
    print_kb "SUPER + F" "Toggle Fullscreen"
    print_kb "SUPER + Arrows" "Move Focus"
    echo ""

    echo -e "${BOLD}${C_BLUE}--- System ---${RESET}"
    print_kb "Print Screen" "Screenshot"
    print_kb "SUPER + ALT + S" "Toggle Night Mode"
    print_kb "ALT + SHIFT" "Switch Keyboard Layout"
    echo ""

    echo -e "${BOLD}${C_GREEN}Press ENTER to return...${RESET}"
    read -r
}

# ==============================================================================
# Main Menu
# ==============================================================================
clear
while true; do
    draw_header

    S_PKG="${C_YELLOW}[-]${RESET}"
    S_OVW="${C_YELLOW}[-]${RESET}"
    S_KBD=$( [ "$VISITED_KEYBOARD" = true ] && echo -e "${C_GREEN}[✓]${RESET}" || echo -e "${C_RED}[ ]${RESET}" )

    MENU_ITEMS="1. $S_PKG ${C_GREEN}Manage Packages${RESET} [${#PKGS[@]} queued, Optional]\n"
    MENU_ITEMS+="2. $S_OVW ${C_CYAN}Overview & Keybinds${RESET} [Optional]\n"
    MENU_ITEMS+="3. $S_KBD ${C_BLUE}Keyboard Layout Setup${RESET} [${KB_LAYOUTS_DISPLAY:-$KB_LAYOUTS}]\n"
    MENU_ITEMS+="4. ${BOLD}${C_MAGENTA}START INSTALLATION${RESET}\n"
    MENU_ITEMS+="5. ${DIM}Exit${RESET}"

    MENU_OPTION=$(echo -e "$MENU_ITEMS" | fzf \
        --ansi --layout=reverse --border=rounded --margin=1,2 --height=15 \
        --prompt=" Main Menu > " --pointer=">" \
        --header=" Navigate with ARROWS. Select with ENTER. ")

    case "$MENU_OPTION" in
        *"1"*) manage_packages ;;
        *"2"*) show_overview ;;
        *"3"*) manage_keyboard ;;
        *"4"*)
            if [ "$VISITED_KEYBOARD" = false ]; then
                echo -e "\n${C_RED}[!] Please configure Keyboard Layout first.${RESET}"; sleep 2; continue
            fi
            break ;;
        *"5"*) clear; exit 0 ;;
        *) exit 0 ;;
    esac
done

# ==============================================================================
# Installation
# ==============================================================================
clear; draw_header
echo -e "${BOLD}${C_BLUE}::${RESET} ${BOLD}Starting Installation...${RESET}\n"

# Ping hit counter
curl -s "https://hits.sh/github.com/Pikalev15/hyprlev" >/dev/null 2>&1 &

echo -e "${C_CYAN}[ INFO ]${RESET} Requesting sudo..."
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# --- 1. Install Packages ---
MISSING_PKGS=()
echo -e "\n${C_CYAN}[ INFO ]${RESET} Checking installed packages..."
for pkg in "${PKGS[@]}"; do
    [[ -z "$pkg" ]] && continue
    pacman -Q "$pkg" &>/dev/null || MISSING_PKGS+=("$pkg")
done

if [ ${#MISSING_PKGS[@]} -eq 0 ]; then
    echo -e "  -> ${C_GREEN}All packages already installed.${RESET}\n"
else
    echo -e "  -> ${C_YELLOW}${#MISSING_PKGS[@]} packages to install.${RESET}\n"
    for pkg in "${MISSING_PKGS[@]}"; do
        echo -e "\n${C_CYAN}=====================================================${RESET}"
        echo -e "${C_BLUE}::${RESET} ${BOLD}Installing ${pkg}...${RESET}"
        echo -e "${C_CYAN}=====================================================${RESET}"
        SAFE_JOBS=$(( $(nproc) / 2 )); [[ $SAFE_JOBS -lt 1 ]] && SAFE_JOBS=1; [[ $SAFE_JOBS -gt 4 ]] && SAFE_JOBS=4
        if yes "Y" | env MAKEFLAGS="-j$SAFE_JOBS" $PKG_MANAGER "$pkg"; then
            echo -e "\n${C_GREEN}[ OK ] $pkg${RESET}"
        else
            echo -e "\n${C_RED}[ FAILED ] $pkg${RESET}"
            FAILED_PKGS+=("$pkg")
        fi
    done
fi

# --- 2. Clone Dotfiles ---
echo -e "\n${C_CYAN}[ INFO ]${RESET} Setting up dotfiles..."
REPO_URL="https://github.com/Pikalev15/hyprlev.git"
CLONE_DIR="$HOME/hyprlev"

if [ -d "$CLONE_DIR" ]; then
    echo -e "  -> Pulling latest changes..."
    git -C "$CLONE_DIR" fetch --all >/dev/null 2>&1
    git -C "$CLONE_DIR" reset --hard @{u} >/dev/null 2>&1
else
    git clone "$REPO_URL" "$CLONE_DIR" >/dev/null 2>&1
fi
printf "  -> Dotfiles ready %-25s ${C_GREEN}[ OK ]${RESET}\n" ""

# --- 3. Backup & Stow ---
echo -e "\n${C_CYAN}[ INFO ]${RESET} Backing up existing configs..."
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

CONFIG_DIRS=(ags btop cava drift fish gtk-3.0 gtk-4.0 hypr kitty nwg-dock-hyprland nwg-look quickshell rofi snappy-switcher swaync themes waybar wlogout)

for dir in "${CONFIG_DIRS[@]}"; do
    TARGET="$HOME/.config/$dir"
    if [ -d "$TARGET" ] && [ ! -L "$TARGET" ]; then
        mv "$TARGET" "$BACKUP_DIR/$dir"
        printf "  -> Backed up %-30s ${C_YELLOW}[ SAVED ]${RESET}\n" "$dir"
    elif [ -L "$TARGET" ]; then
        rm "$TARGET"
    fi
done

echo -e "\n${C_CYAN}[ INFO ]${RESET} Stowing configs..."
cd "$CLONE_DIR/configs"
for dir in */; do
    if stow --target="$HOME" "$dir" 2>/dev/null; then
        printf "  -> Stowed %-33s ${C_GREEN}[ OK ]${RESET}\n" "${dir%/}"
    else
        printf "  -> Skipped %-32s ${C_YELLOW}[ CONFLICT ]${RESET}\n" "${dir%/}"
    fi
done

# --- 3. Apply Keyboard Layout ---
echo -e "\n${C_CYAN}[ INFO ]${RESET} Applying keyboard layout..."
HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
if [ -f "$HYPR_CONF" ]; then
    sed -i "s/^ *kb_layout =.*/    kb_layout = $KB_LAYOUTS/" "$HYPR_CONF"
    if [ -n "$KB_OPTIONS" ]; then
        sed -i "s/^ *kb_options =.*/    kb_options = $KB_OPTIONS/" "$HYPR_CONF"
    else
        sed -i "s/^ *kb_options =.*/    kb_options = /" "$HYPR_CONF"
    fi
    printf "  -> Keyboard layout applied %-18s ${C_GREEN}[ OK ]${RESET}\n" ""
else
    echo -e "  -> ${C_YELLOW}hyprland.conf not found, skipping keyboard injection.${RESET}"
fi

# --- 4. Enable Services ---
echo -e "\n${C_CYAN}[ INFO ]${RESET} Enabling services..."
sudo systemctl enable NetworkManager.service 2>/dev/null
sudo systemctl --global enable pipewire wireplumber pipewire-pulse 2>/dev/null || true
systemctl --user start pipewire wireplumber pipewire-pulse 2>/dev/null || true
sudo systemctl enable --now swayosd-libinput-backend.service 2>/dev/null || true
printf "  -> Services enabled %-25s ${C_GREEN}[ OK ]${RESET}\n" ""

# --- 7. Save Version State ---
cat <<EOF > "$VERSION_FILE"
LOCAL_VERSION="$DOTS_VERSION"
KB_LAYOUTS="$KB_LAYOUTS"
KB_LAYOUTS_DISPLAY="$KB_LAYOUTS_DISPLAY"
KB_OPTIONS="$KB_OPTIONS"
EOF

# ==============================================================================
# Done
# ==============================================================================
echo -e "\n${BOLD}${C_GREEN}"
cat << "EOF"
  ___ _  _ ___ _____ _   _    _      _ _____ ___ ___  _  _    ___  ___  _  _ ___ _ 
 |_ _| \| / __|_   _/_\ | |  | |    /_\_   _|_ _/ _ \| \| |  |   \/ _ \| \| | __| |
  | || .` \__ \ | |/ _ \| |__| |__ / _ \| |  | | (_) | .` |  | |) | (_) | .` | _|| |
 |___|_|\_|___/ |_/_/ \_\____|____/_/ \_\_| |___\___/|_|\_|  |___/ \___/|_|\_|___|_|
EOF
echo -e "${RESET}\n"

echo -e "${BOLD}${C_MAGENTA}=================================================================${RESET}"
echo -e " Old configs backed up to: ${C_CYAN}$BACKUP_DIR${RESET}"
echo -e " Log out and back in, or run ${C_CYAN}Hyprland${RESET} to apply changes."
echo -e "${BOLD}${C_MAGENTA}=================================================================${RESET}\n"

if [ ${#FAILED_PKGS[@]} -ne 0 ]; then
    echo -e "${BOLD}${C_RED}Failed packages (install manually):${RESET}"
    for fp in "${FAILED_PKGS[@]}"; do echo -e "  - ${C_YELLOW}$fp${RESET}"; done
    echo ""
fi

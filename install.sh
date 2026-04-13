#!/bin/bash
set -e

# ── Colors ──────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

ask() { read -p "$(echo -e "${CYAN}$1${RESET} [y/N] ")" ans; [[ "$ans" =~ ^[Yy]$ ]]; }
info() { echo -e "${GREEN}==>${RESET} ${BOLD}$1${RESET}"; }
warn() { echo -e "${YELLOW}[!]${RESET} $1"; }

# ── Ping counter ────────────────────────────────────────────────
curl -s "https://hits.sh/github.com/Pikalev15/hyprlev" > /dev/null 2>&1 &

clear
echo -e "${BOLD}${CYAN}"
echo "  ██╗  ██╗██╗   ██╗██████╗ ██████╗ ██╗     ███████╗██╗   ██╗"
echo "  ██║  ██║╚██╗ ██╔╝██╔══██╗██╔══██╗██║     ██╔════╝██║   ██║"
echo "  ███████║ ╚████╔╝ ██████╔╝██████╔╝██║     █████╗  ██║   ██║"
echo "  ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══██╗██║     ██╔══╝  ╚██╗ ██╔╝"
echo "  ██║  ██║   ██║   ██║     ██║  ██║███████╗███████╗ ╚████╔╝ "
echo "  ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝  ╚═══╝  "
echo -e "${RESET}"
echo -e "  ${BOLD}Levi's Hyprland Dotfiles${RESET} — github.com/Pikalev15/hyprlev"
echo ""


# ── Sudo ────────────────────────────────────────────────────────
info "Requesting sudo..."
sudo -v
# Keep sudo alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ── Dependencies ────────────────────────────────────────────────
echo ""
info "Step 1: Install dependencies"
if ask "Install stow and git via pacman?"; then
    sudo pacman -S --needed stow git
else
    warn "Skipping. Make sure stow and git are installed."
fi

# ── Clone ───────────────────────────────────────────────────────
echo ""
info "Step 2: Clone dotfiles"
if [ -d "$HOME/hyprlev" ]; then
    warn "~/hyprlev already exists."
    if ask "Pull latest changes instead?"; then
        git -C "$HOME/hyprlev" pull
    fi
else
    if ask "Clone dotfiles to ~/hyprlev?"; then
        git clone https://github.com/Pikalev15/hyprlev.git "$HOME/hyprlev"
    fi
fi

# ── Backup ──────────────────────────────────────────────────────
echo ""
info "Step 3: Backup existing configs"
if ask "Backup existing ~/.config entries to ~/.config.bak?"; then
    mkdir -p "$HOME/.config.bak"
    for dir in ags btop cava drift fish gtk-3.0 gtk-4.0 hypr kitty \
                nwg-dock-hyprland nwg-look quickshell rofi snappy-switcher \
                swaync themes waybar wlogout; do
        if [ -d "$HOME/.config/$dir" ] && [ ! -L "$HOME/.config/$dir" ]; then
            cp -r "$HOME/.config/$dir" "$HOME/.config.bak/"
            echo "  Backed up $dir"
        fi
    done
    info "Backup saved to ~/.config.bak"
else
    warn "Skipping backup."
fi

# ── Stow ────────────────────────────────────────────────────────
echo ""
info "Step 4: Stow dotfiles"
if ask "Stow all config packages?"; then
    cd "$HOME/hyprlev/configs"
    for dir in */; do
        stow --target="$HOME" "$dir" 2>/dev/null && echo "  Stowed ${dir%/}" || warn "Conflict in ${dir%/}, skipping"
    done
else
    warn "Skipping stow."
fi

# ── Done ────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}All done!${RESET} Log out and back in, or run ${CYAN}Hyprland${RESET} to start."
echo ""

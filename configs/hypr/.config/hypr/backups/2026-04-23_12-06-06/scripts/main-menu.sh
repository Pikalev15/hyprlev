#!/bin/bash

# Terminal to use
TERMINAL="kitty"
# Browser to use
BROWSER="chromium"
# Rofi config
ROFI_CONFIG="$HOME/.config/rofi/configs/main-menu.rasi"

# Rofi wrapper — passes config if the file exists
rofi_cmd() {
    if [ -f "$ROFI_CONFIG" ]; then
        rofi -config "$ROFI_CONFIG" "$@"
    else
        rofi "$@"
    fi
}

# Main menu options
show_main_menu() {
    echo "󰀻 Apps"
    echo "󱂬 TUI Apps"
    echo "󰏔 Install"
    echo "󰚰 Update"
    echo "󰆴 Remove"
    echo "󱐋 Performance"
    echo "󰖩 WiFi"
    echo "󰂯 Bluetooth"
    echo "󰒓 Tools"
    echo "󰲌 Projects"
    echo "󱡶 Services"
    echo "󰅬 Scripts"
    echo "󰌌 Keybinds"
    echo "󰒓 Task Manager"
    echo "󰐥 System"
}

# Apps menu
show_apps() {
    rofi_cmd -show drun -i
}

# Tools menu
show_tools() {
    TOOL=$(echo -e "󰹑 Screenshot Area\n󰹑 Screenshot Full\n󰈋 Color Picker\n󰅖 Clipboard Manager\n󰃨 Wallpaper Selector\n󰌌 Emoji Picker" | rofi_cmd -dmenu -i -p "Tools")
    
    case "$TOOL" in
        *"Screenshot Area")
            grim -g "$(slurp)" ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png
            ;;
        *"Screenshot Full")
            grim -o $(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name') ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png
            ;;
        *"Color Picker")
            hyprpicker -a
            ;;
        *"Clipboard Manager")
            cliphist list | rofi_cmd -dmenu -i -p "Clipboard" | cliphist decode | wl-copy
            ;;
        *"Wallpaper Selector")
            ~/.config/themes/wallpaper-selector.sh
            ;;
        *"Emoji Picker")
            rofi_cmd -show emoji -i
            ;;
    esac
}

# Improved browser detection
detect_browser() {
    # Check for browsers in order of preference
    for browser in brave brave-browser google-chrome-stable google-chrome chromium firefox; do
        if command -v "$browser" >/dev/null 2>&1; then
            echo "$browser"
            return 0
        fi
    done
    return 1
}

# Install menu
show_install() {
    MANAGER=$(echo -e "󰏖 Pacman\n󰣇 Yay\n󰖟 PWA (Web App)" | rofi_cmd -dmenu -i -p "Install with")
    
    case "$MANAGER" in
        *"Pacman")
            PACKAGE=$(pacman -Slq | rofi_cmd -dmenu -i -p "Install package")
            if [ -n "$PACKAGE" ]; then
                $TERMINAL -e bash -c "sudo pacman -S $PACKAGE --noconfirm; read -p 'Press enter to close...'"
            fi
            ;;
        *"Yay")
            PACKAGE=$(yay -Slq | rofi_cmd -dmenu -i -p "Install package")
            if [ -n "$PACKAGE" ]; then
                $TERMINAL -e bash -c "yay -S $PACKAGE --noconfirm; read -p 'Press enter to close...'"
            fi
            ;;
        *"PWA"*)
            URL=$(echo "" | rofi_cmd -dmenu -p "Enter website URL")
            if [ -n "$URL" ]; then
                # Add https:// if not present
                if [[ ! "$URL" =~ ^https?:// ]]; then
                    URL="https://$URL"
                fi
                
                APP_NAME=$(echo "" | rofi_cmd -dmenu -i -p "Enter app name" -lines 0)
                if [ -n "$APP_NAME" ]; then
                    # Detect browser
                    BROWSER_CMD=$(detect_browser)
                    if [ $? -eq 0 ]; then
                        # Create directories
                        DESKTOP_FILE="$HOME/.local/share/applications/${APP_NAME// /-}.desktop"
                        ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
                        mkdir -p "$HOME/.local/share/applications"
                        mkdir -p "$ICON_DIR"
                        
                        # Download favicon
                        ICON_NAME="${APP_NAME// /-}"
                        ICON_PATH="$ICON_DIR/$ICON_NAME.png"
                        
                        # Try multiple favicon locations
                        FAVICON_URLS=(
                            "${URL}/favicon.ico"
                            "${URL}/favicon.png"
                            "https://www.google.com/s2/favicons?domain=${URL}&sz=256"
                        )
                        
                        FAVICON_DOWNLOADED=false
                        for FAVICON_URL in "${FAVICON_URLS[@]}"; do
                            if curl -s -L -f "$FAVICON_URL" -o "$ICON_PATH" 2>/dev/null; then
                                # Convert to PNG if it's an ICO file
                                if file "$ICON_PATH" | grep -q "MS Windows icon"; then
                                    if command -v convert >/dev/null 2>&1; then
                                        convert "$ICON_PATH" "$ICON_PATH" 2>/dev/null
                                    fi
                                fi
                                FAVICON_DOWNLOADED=true
                                break
                            fi
                        done
                        
                        # Fallback to generic icon if download failed
                        if [ "$FAVICON_DOWNLOADED" = false ]; then
                            ICON_NAME="web-browser"
                            notify-send "PWA" "Could not download favicon, using default icon"
                        fi
                        
                        # Different app mode syntax for different browsers
                        case "$BROWSER_CMD" in
                            *brave* | *chrome*)
                                APP_CMD="$BROWSER_CMD --app=$URL"
                                ;;
                            *firefox*)
                                APP_CMD="$BROWSER_CMD --new-window $URL"
                                ;;
                            *)
                                APP_CMD="$BROWSER_CMD --app=$URL"
                                ;;
                        esac
                        
                        # Create desktop entry
                        cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_NAME
Exec=$APP_CMD
Icon=$ICON_NAME
Categories=Network;WebBrowser;
Terminal=false
StartupNotify=true
EOF
                        chmod +x "$DESKTOP_FILE"
                        
                        # Update icon cache
                        if command -v gtk-update-icon-cache >/dev/null 2>&1; then
                            gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor 2>/dev/null
                        fi
                        
                        notify-send "PWA Installed" "$APP_NAME created successfully\nBrowser: $BROWSER_CMD"
                    else
                        notify-send "PWA Error" "No supported browser found\nInstall Brave, Chrome, Chromium, or Firefox"
                    fi
                fi
            fi
            ;;
    esac
}

# Update menu - ENHANCED
show_update() {
    MANAGER=$(echo -e "󰏖 Pacman\n󰣇 Yay\n󰚰 All Packages (Pacman & Yay)" | rofi_cmd -dmenu -i -p "Update with")
    
    case "$MANAGER" in
        *"All Packages"*)
            $TERMINAL -e bash -c "echo 'Updating all packages...'; yay -Syu --noconfirm; echo 'Update complete!'; read -p 'Press enter to close...'"
            ;;
        *"Pacman")
            $TERMINAL -e bash -c "sudo pacman -Syu --noconfirm; read -p 'Press enter to close...'"
            ;;
        *"Yay")
            $TERMINAL -e bash -c "yay -Syu --noconfirm; read -p 'Press enter to close...'"
            ;;
    esac
}

# Remove menu - ENHANCED with PWA support
show_remove() {
    MANAGER=$(echo -e "󰏖 System Package\n󰖟 PWA (Web App)" | rofi_cmd -dmenu -i -p "Remove")
    
    case "$MANAGER" in
        *"System Package")
            PACKAGE=$(pacman -Qq | rofi_cmd -dmenu -i -p "Remove package")
            
            if [ -n "$PACKAGE" ]; then
                if pacman -Qm | grep -q "^$PACKAGE "; then
                    $TERMINAL -e bash -c "yay -R $PACKAGE; read -p 'Press enter to close...'"
                else
                    $TERMINAL -e bash -c "sudo pacman -R $PACKAGE; read -p 'Press enter to close...'"
                fi
            fi
            ;;
        *"PWA"*)
            # Find all PWA desktop files
            PWA_DIR="$HOME/.local/share/applications"
            if [ ! -d "$PWA_DIR" ]; then
                notify-send "PWA Remove" "No PWA applications found"
                return
            fi
            
            # List all desktop files and extract PWA apps (those with browser --app flag)
            PWA_LIST=$(find "$PWA_DIR" -name "*.desktop" -type f -exec grep -l "app=" {} \; 2>/dev/null | while read -r file; do
                APP_NAME=$(grep "^Name=" "$file" | cut -d'=' -f2)
                if [ -n "$APP_NAME" ]; then
                    echo "$APP_NAME|$file"
                fi
            done)
            
            if [ -z "$PWA_LIST" ]; then
                notify-send "PWA Remove" "No PWA applications found"
                return
            fi
            
            # Show PWA list in rofi
            SELECTED=$(echo "$PWA_LIST" | cut -d'|' -f1 | rofi_cmd -dmenu -i -p "Select PWA to remove")
            
            if [ -n "$SELECTED" ]; then
                # Find the desktop file path
                DESKTOP_FILE=$(echo "$PWA_LIST" | grep "^$SELECTED|" | cut -d'|' -f2)
                
                if [ -n "$DESKTOP_FILE" ] && [ -f "$DESKTOP_FILE" ]; then
                    # Extract icon name
                    ICON_NAME=$(grep "^Icon=" "$DESKTOP_FILE" | cut -d'=' -f2)
                    
                    # Confirm deletion
                    CONFIRM=$(echo -e "Yes\nNo" | rofi_cmd -dmenu -i -p "Remove $SELECTED?")
                    
                    if [ "$CONFIRM" = "Yes" ]; then
                        # Remove desktop file
                        rm -f "$DESKTOP_FILE"
                        
                        # Remove icon if it's a custom PWA icon
                        if [ -n "$ICON_NAME" ] && [ "$ICON_NAME" != "web-browser" ]; then
                            ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"
                            if [ -f "$ICON_DIR/$ICON_NAME.png" ]; then
                                rm -f "$ICON_DIR/$ICON_NAME.png"
                            fi
                        fi
                        
                        # Update icon cache
                        if command -v gtk-update-icon-cache >/dev/null 2>&1; then
                            gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor 2>/dev/null
                        fi
                        
                        # Update desktop database
                        if command -v update-desktop-database >/dev/null 2>&1; then
                            update-desktop-database "$PWA_DIR" 2>/dev/null
                        fi
                        
                        notify-send "PWA Removed" "$SELECTED has been removed successfully"
                    fi
                else
                    notify-send "PWA Remove" "Error: Desktop file not found"
                fi
            fi
            ;;
    esac
}

# Performance menu
show_performance() {
    # Get current power profile
    CURRENT=$(powerprofilesctl get)
    
    # Build menu with active indicator
    MENU=""
    if [ "$CURRENT" = "performance" ]; then
        MENU+="󰓅 Performance (Active)\n"
    else
        MENU+="󰓅 Performance\n"
    fi
    
    if [ "$CURRENT" = "balanced" ]; then
        MENU+="󰾅 Balanced (Active)\n"
    else
        MENU+="󰾅 Balanced\n"
    fi
    
    if [ "$CURRENT" = "power-saver" ]; then
        MENU+="󰾆 Power Saver (Active)"
    else
        MENU+="󰾆 Power Saver"
    fi
    
    PROFILE=$(echo -e "$MENU" | rofi_cmd -dmenu -i -p "Power Profile")
    
    case "$PROFILE" in
        *"Performance"*)
            powerprofilesctl set performance
            notify-send "Power Profile" "Switched to Performance mode"
            ;;
        *"Balanced"*)
            powerprofilesctl set balanced
            notify-send "Power Profile" "Switched to Balanced mode"
            ;;
        *"Power Saver"*)
            powerprofilesctl set power-saver
            notify-send "Power Profile" "Switched to Power Saver mode"
            ;;
    esac
}

# WiFi menu
show_wifi() {
    ACTION=$(echo -e "󰖩 Connect/Disconnect\n󰖩 Turn On\n󰖪 Turn Off\n󰑓 Restart" | rofi_cmd -dmenu -i -p "WiFi")
    
    case "$ACTION" in
        *"Connect/Disconnect")
            NETWORK=$(nmcli -f SSID,SIGNAL,SECURITY device wifi list | tail -n +2 | rofi_cmd -dmenu -i -p "Select Network")
            if [ -n "$NETWORK" ]; then
                SSID=$(echo "$NETWORK" | awk '{print $1}')
                if nmcli connection show --active | grep -q "$SSID"; then
                    nmcli connection down "$SSID"
                    notify-send "WiFi" "Disconnected from $SSID"
                else
                    PASSWORD=$(rofi_cmd -dmenu -password -p "Password for $SSID")
                    if [ -n "$PASSWORD" ]; then
                        nmcli device wifi connect "$SSID" password "$PASSWORD"
                        notify-send "WiFi" "Connected to $SSID"
                    fi
                fi
            fi
            ;;
        *"Turn On")
            nmcli radio wifi on
            notify-send "WiFi" "WiFi turned on"
            ;;
        *"Turn Off")
            nmcli radio wifi off
            notify-send "WiFi" "WiFi turned off"
            ;;
        *"Restart")
            nmcli radio wifi off && sleep 2 && nmcli radio wifi on
            notify-send "WiFi" "WiFi restarted"
            ;;
    esac
}

# Bluetooth menu
show_bluetooth() {
    ACTION=$(echo -e "󰂯 Connect/Disconnect\n󰂯 Turn On\n󰂲 Turn Off\n󰑓 Restart" | rofi_cmd -dmenu -i -p "Bluetooth")
    
    case "$ACTION" in
        *"Connect/Disconnect")
            # Build device list with connection status
            DEVICE_LIST=$(bluetoothctl devices | sed 's/Device //' | while read -r line; do
                MAC=$(echo "$line" | awk '{print $1}')
                NAME=$(echo "$line" | cut -d' ' -f2-)
                if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
                    echo "$MAC $NAME (Connected)"
                else
                    echo "$MAC $NAME"
                fi
            done)
            
            DEVICE=$(echo "$DEVICE_LIST" | rofi_cmd -dmenu -i -p "Select Device")
            if [ -n "$DEVICE" ]; then
                MAC=$(echo "$DEVICE" | awk '{print $1}')
                if bluetoothctl info "$MAC" | grep -q "Connected: yes"; then
                    bluetoothctl disconnect "$MAC"
                    notify-send "Bluetooth" "Disconnected from device"
                else
                    bluetoothctl connect "$MAC"
                    notify-send "Bluetooth" "Connected to device"
                fi
            fi
            ;;
        *"Turn On")
            bluetoothctl power on
            notify-send "Bluetooth" "Bluetooth turned on"
            ;;
        *"Turn Off")
            bluetoothctl power off
            notify-send "Bluetooth" "Bluetooth turned off"
            ;;
        *"Restart")
            bluetoothctl power off && sleep 2 && bluetoothctl power on
            notify-send "Bluetooth" "Bluetooth restarted"
            ;;
    esac
}

# Task Manager
show_task_manager() {
    $TERMINAL -e btop
}

# TUI Apps menu - ENHANCED with descriptions and more tools
show_tui() {
    TUI_APP=$(echo -e "󰒍 yazi (File Manager)\n󰚝 btop (System Monitor)\n󰅬 acpi (Battery Health)\n󱂬 lazygit (Git TUI)\n󰩟 nmon (Performance Monitor)\n󰖟 nethogs (Network Monitor)\n󰒍 ranger (File Manager)\n󰹑 s-tui (CPU Stress Test)" | rofi_cmd -dmenu -i -p "TUI Apps")
    
    case "$TUI_APP" in
        *"yazi"*)
            if command -v yazi >/dev/null 2>&1; then
                $TERMINAL -e yazi
            else
                notify-send "TUI Apps" "yazi not installed\nInstall: yay -S yazi"
            fi
            ;;
        *"btop"*)
            if command -v btop >/dev/null 2>&1; then
                $TERMINAL -e btop
            else
                notify-send "TUI Apps" "btop not installed\nInstall: sudo pacman -S btop"
            fi
            ;;
        *"acpi"*)
            if command -v acpi >/dev/null 2>&1; then
                $TERMINAL -e bash -c "acpi -i; read -p 'Press enter to close...'"
            else
                notify-send "TUI Apps" "acpi not installed\nInstall: sudo pacman -S acpi"
            fi
            ;;
        *"lazygit"*)
            if command -v lazygit >/dev/null 2>&1; then
                $TERMINAL -e lazygit
            else
                notify-send "TUI Apps" "lazygit not installed\nInstall: yay -S lazygit"
            fi
            ;;
        *"nmon"*)
            if command -v nmon >/dev/null 2>&1; then
                $TERMINAL -e nmon
            else
                notify-send "TUI Apps" "nmon not installed\nInstall: yay -S nmon"
            fi
            ;;
        *"nethogs"*)
            if command -v nethogs >/dev/null 2>&1; then
                $TERMINAL -e bash -c "sudo nethogs; read -p 'Press enter to close...'"
            else
                notify-send "TUI Apps" "nethogs not installed\nInstall: sudo pacman -S nethogs"
            fi
            ;;
        *"ctop"*)
            if command -v ctop >/dev/null 2>&1; then
                $TERMINAL -e ctop
            else
                notify-send "TUI Apps" "ctop not installed\nInstall: yay -S ctop-bin"
            fi
            ;;
        *"s-tui"*)
            if command -v s-tui >/dev/null 2>&1; then
                $TERMINAL -e s-tui
            else
                notify-send "TUI Apps" "s-tui not installed\nInstall: yay -S s-tui"
            fi
            ;;
    esac
}

# Scripts menu
show_scripts() {
    ACTION=$(echo -e "󰑓 Reload Hyprland Config\n󰚰 Update All Packages\n󰩺 Clear Cache\n󰃨 Change Wallpaper\n󰖟 Restart Network" | rofi_cmd -dmenu -i -p "Scripts")
    
    case "$ACTION" in
        *"Reload Hyprland Config")
            hyprctl reload
            notify-send "Scripts" "Hyprland config reloaded"
            ;;
        *"Update All Packages")
            $TERMINAL -e bash -c "yay -Syu --noconfirm; read -p 'Press enter to close...'"
            ;;
        *"Clear Cache")
            $TERMINAL -e bash -c "yay -Sc --noconfirm; sudo pacman -Sc --noconfirm; read -p 'Press enter to close...'"
            notify-send "Scripts" "Cache cleared"
            ;;
        *"Change Wallpaper")
            ~/.config/themes/wallpaper-selector.sh
            ;;
        *"Restart Network")
            $TERMINAL -e bash -c "sudo systemctl restart NetworkManager; read -p 'Press enter to close...'"
            notify-send "Scripts" "Network restarted"
            ;;
    esac
}

# Services menu
show_services() {
    SERVICE=$(echo -e "󰒃 UFW\n󰛳 Tailscale\n󰣀 SSH\n󰍹 GDM\n󰖟 NetworkManager\n󰂯 Bluetooth" | rofi_cmd -dmenu -i -p "Services")
    
    if [ -z "$SERVICE" ]; then
        return
    fi
    
    case "$SERVICE" in
        *"UFW")
            SERVICE_NAME="ufw"
            ;;
        *"Tailscale")
            SERVICE_NAME="tailscaled"
            ;;
        *"SSH")
            SERVICE_NAME="sshd"
            ;;
        *"NetworkManager")
            SERVICE_NAME="NetworkManager"
            ;;
        *"GDM")
            SERVICE_NAME="gdm"
            ;;
        *"Bluetooth")
            SERVICE_NAME="bluetooth"
            ;;
        *)
            return
            ;;
    esac
    
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        STATUS="Active"
        ACTION=$(echo -e "󰓛 Stop\n󰑓 Restart\n󰋗 Status" | rofi_cmd -dmenu -i -p "$SERVICE_NAME ($STATUS)")
    else
        STATUS="Inactive"
        ACTION=$(echo -e "󰐊 Start\n󰋗 Status" | rofi_cmd -dmenu -i -p "$SERVICE_NAME ($STATUS)")
    fi
    
    case "$ACTION" in
        *"Start")
            $TERMINAL -e bash -c "sudo systemctl start $SERVICE_NAME; echo 'Service started. Press enter to close...'; read"
            notify-send "Services" "$SERVICE_NAME started"
            ;;
        *"Stop")
            if [ "$SERVICE_NAME" = "docker" ]; then
                $TERMINAL -e bash -c "sudo systemctl stop docker docker.socket; echo 'Docker and docker.socket stopped. Press enter to close...'; read"
                notify-send "Services" "Docker and docker.socket stopped"
            else
                $TERMINAL -e bash -c "sudo systemctl stop $SERVICE_NAME; echo 'Service stopped. Press enter to close...'; read"
                notify-send "Services" "$SERVICE_NAME stopped"
            fi
            ;;
        *"Restart")
            $TERMINAL -e bash -c "sudo systemctl restart $SERVICE_NAME; echo 'Service restarted. Press enter to close...'; read"
            notify-send "Services" "$SERVICE_NAME restarted"
            ;;
        *"Status")
            $TERMINAL -e bash -c "sudo systemctl status $SERVICE_NAME; read -p 'Press enter to close...'"
            ;;
    esac
}

# Projects menu
show_projects() {
    DIRS=$(find ~/hyprlev ~/hyprlev/* ~/hyprlev/*/* ~/hyprlev/*/*/* ~/Pikalev15 ~/hyprlev-git -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sed "s|^$HOME/||")
    
    if [ -z "$DIRS" ]; then
        notify-send "Projects" "No directories found"
        return
    fi
    
    SELECTED=$(echo "$DIRS" | rofi_cmd -dmenu -i -p "📁 Select Project Directory")
    
    if [ -z "$SELECTED" ]; then
        return
    fi
    
    SELECTED_PATH="$HOME/$SELECTED"
    SELECTED_NAME=$(basename "$SELECTED_PATH" | tr . _)
    
    if [ -d "$SELECTED_PATH" ]; then
        if [[ -n $TMUX ]]; then
            tmux new-window -c "$SELECTED_PATH" -n "$SELECTED_NAME" "nvim ."
        else
            $TERMINAL --working-directory="$SELECTED_PATH" -e nvim . &
        fi
        notify-send "Projects" "Opening $SELECTED_NAME in nvim"
    else
        notify-send "Projects" "Error: Directory not found"
    fi
}

# Keybinds menu
show_keybinds() {
    ~/.config/hypr/scripts/keymap-menu.sh
}

# System menu
show_system() {
    ~/.config/hypr/scripts/power-menu.sh
}

# Main logic
CHOICE=$(show_main_menu | rofi_cmd -dmenu -i -p "System Menu")
case "$CHOICE" in
    *"TUI Apps")
        show_tui
        ;;
    *"Apps")
        show_apps
        ;;
    *"Tools")
        show_tools
        ;;
    *"Install")
        show_install
        ;;
    *"Update")
        show_update
        ;;
    *"Remove")
        show_remove
        ;;
    *"Performance")
        show_performance
        ;;
    *"WiFi")
        show_wifi
        ;;
    *"Bluetooth")
        show_bluetooth
        ;;
    *"Task Manager")
        show_task_manager
        ;;
    *"Scripts")
        show_scripts
        ;;
    *"Services")
        show_services
        ;;
    *"Projects")
        show_projects
        ;;
    *"Keybinds")
        show_keybinds
        ;;
    *"System")
        show_system
        ;;
esac

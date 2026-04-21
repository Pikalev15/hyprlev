#!/usr/bin/env bash
# Outputs: name|exec|iconpath|desktop_id per line, sorted case-insensitively.
# iconpath is a resolved absolute file path (or empty if not found).

resolve_icon() {
    local name="$1"
    [ -z "$name" ] && return
    # Already absolute
    if [[ "$name" == /* ]] && [ -f "$name" ]; then echo "$name"; return; fi
    # Priority dirs: prefer 48px png, then scalable svg, then larger sizes, then pixmaps
    local dirs=(
        "$HOME/.local/share/icons/hicolor/48x48/apps"
        "$HOME/.local/share/icons/hicolor/scalable/apps"
        "/usr/share/icons/hicolor/48x48/apps"
        "/usr/share/icons/hicolor/scalable/apps"
        "/usr/share/icons/hicolor/256x256/apps"
        "/usr/share/icons/hicolor/128x128/apps"
        "/usr/share/icons/hicolor/64x64/apps"
        "/usr/share/pixmaps"
        "$HOME/.local/share/icons"
        "/var/lib/flatpak/exports/share/icons/hicolor/scalable/apps"
        "/var/lib/flatpak/exports/share/icons/hicolor/128x128/apps"
        "/var/lib/flatpak/exports/share/icons/hicolor/64x64/apps"
        "$HOME/.local/share/flatpak/exports/share/icons/hicolor/scalable/apps"
    )
    for d in "${dirs[@]}"; do
        [ -f "$d/$name.png" ] && echo "$d/$name.png" && return
        [ -f "$d/$name.svg" ] && echo "$d/$name.svg" && return
        [ -f "$d/$name.xpm" ] && echo "$d/$name.xpm" && return
    done
}

parse_desktop() {
    local f="$1"
    local name="" exec_="" icon="" nodisplay="" type="" categories="" in_entry=0

    while IFS= read -r line; do
        case "$line" in
            "[Desktop Entry]") in_entry=1 ;;
            "["*"]")           [ $in_entry -eq 1 ] && break ;;
        esac
        [ $in_entry -eq 0 ] && continue
        case "$line" in
            Type=*)       type="${line#Type=}" ;;
            Name=*)       [ -z "$name" ]       && name="${line#Name=}" ;;
            Exec=*)       [ -z "$exec_" ]      && exec_="${line#Exec=}" ;;
            Icon=*)       [ -z "$icon" ]       && icon="${line#Icon=}" ;;
            NoDisplay=*)  nodisplay="${line#NoDisplay=}" ;;
            Categories=*) [ -z "$categories" ] && categories="${line#Categories=}" ;;
        esac
    done < "$f"

    [ "$type"      != "Application" ] && return
    [ "$nodisplay" = "true"         ] && return
    [[ "$categories" == *"AudioPlugin"* ]]      && return
    # Skip LSP plugins (hundreds of standalone plugin GUIs, not real apps)
    [[ "$(basename "$f")" == in.lsp_plug.* ]]   && return
    [ -z "$name"  ] && return
    [ -z "$exec_" ] && return

    exec_=$(echo "$exec_" | sed 's/ *%[uUfFdDnNickvm]//g; s/ *@@[^ ]*//g; s/ *--file-forwarding//; s/ *-- *$//')

    local iconpath
    iconpath=$(resolve_icon "$icon")

    echo "$name|$exec_|$iconpath|$(basename "$f" .desktop)"
}

{
    for f in /usr/share/applications/*.desktop; do
        [ -f "$f" ] && parse_desktop "$f"
    done
    for f in "$HOME/.local/share/applications/"*.desktop; do
        [ -f "$f" ] && parse_desktop "$f"
    done
    for f in /var/lib/flatpak/exports/share/applications/*.desktop; do
        [ -f "$f" ] && parse_desktop "$f"
    done
    for f in "$HOME/.local/share/flatpak/exports/share/applications/"*.desktop; do
        [ -f "$f" ] && parse_desktop "$f"
    done
} | sort -f | awk -F'|' '!seen[$1]++'

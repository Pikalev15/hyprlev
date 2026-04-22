import "core"
import "services"
import "widgets"
import "panels/StatusBar"
import "panels/Dashboard"
import "panels/QuickSettings"

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    id: root

    // Core Panels
    StatusBar {}
    MusicHoverMenu {}
    Dashboard {
        id: dashboard
    }
    QuickSettings {
        id: quickSettings
    }
    DesktopContextMenu {
        id: desktopContextMenu
    }

    // Global IPC to toggle panels
    IpcHandler {
        target: "dashboard"
        function open() { GlobalStates.dashboardOpen = true }
        function close() { GlobalStates.dashboardOpen = false }
        function toggle() { GlobalStates.dashboardOpen = !GlobalStates.dashboardOpen }
    }

    IpcHandler {
        target: "quicksettings"
        function open() { GlobalStates.quickSettingsOpen = true }
        function close() { GlobalStates.quickSettingsOpen = false }
        function toggle() { GlobalStates.quickSettingsOpen = !GlobalStates.quickSettingsOpen }
    }
}

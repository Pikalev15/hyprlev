// modules/Workspaces.qml — Hyprland workspace indicators
// Uses Quickshell.Hyprland: Hyprland singleton + HyprlandWorkspace model
import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: root
    spacing: 4

    Repeater {
        model: 5

        delegate: WorkspaceButton {
            required property int index
            wsIndex: index + 1

            // Hyprland.focusedMonitor.activeWorkspace is the focused workspace object
            active: Hyprland.focusedMonitor != null
                 && Hyprland.focusedMonitor.activeWorkspace != null
                 && Hyprland.focusedMonitor.activeWorkspace.id === wsIndex

            // A workspace is "occupied" if it exists in Hyprland.workspaces
            occupied: {
                for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                    if (Hyprland.workspaces.values[i].id === wsIndex)
                        return true
                }
                return false
            }
        }
    }
}

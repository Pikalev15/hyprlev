import "../../core"
import "../../services"
import "../../widgets"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

/**
 * Music menu that appears on island hover, using MediaNotchPopup logic.
 */
Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        id: panelWindow
        required property var modelData
        screen: modelData

        readonly property bool isActive: GlobalStates.activeScreen === modelData
        visible: GlobalStates.musicMenuOpen && isActive
        
        exclusiveZone: 0
        WlrLayershell.namespace: "island:musicmenu"
        WlrLayershell.layer: WlrLayer.Overlay
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // Use the MediaNotchPopup layout/content directly here
        MediaNotchPopup {
            modelData: panelWindow.modelData
        }
    }
}

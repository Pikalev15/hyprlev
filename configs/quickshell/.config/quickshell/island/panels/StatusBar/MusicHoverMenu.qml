import "../../core"
import "../../services"
import "../../widgets"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

/**
 * Music menu that appears on island hover.
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

        Item {
            anchors.top: parent.top
            anchors.topMargin: Appearance.sizes.statusBarHeight + 10 * Appearance.effectiveScale
            anchors.horizontalCenter: parent.horizontalCenter
            width: musicWidget.width
            height: musicWidget.height

            MusicWidget {
                id: musicWidget
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: GlobalStates.islandHovered = true
                    onExited: GlobalStates.islandHovered = false
                }
            }
        }
    }
}

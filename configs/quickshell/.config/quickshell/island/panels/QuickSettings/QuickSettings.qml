import "../../core"
import "../../services"
import "../../widgets"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

/**
 * Centered Quick Settings panel.
 */
Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        id: panelWindow
        required property var modelData
        screen: modelData

        readonly property bool isActive: GlobalStates.activeScreen === modelData
        visible: (GlobalStates.quickSettingsOpen && isActive) || content.opacity > 0
        
        exclusiveZone: 0
        WlrLayershell.namespace: "island:quicksettings"
        WlrLayershell.layer: ((GlobalStates.quickSettingsOpen || content.opacity > 0) && isActive) ? WlrLayer.Overlay : WlrLayer.Background
        WlrLayershell.keyboardFocus: (GlobalStates.quickSettingsOpen && isActive) ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // Close when clicking outside
        MouseArea {
            anchors.fill: parent
            onClicked: GlobalStates.quickSettingsOpen = false
        }

        HyprlandFocusGrab {
            id: focusGrab
            active: GlobalStates.quickSettingsOpen && !GlobalStates.isPickingFile && isActive
            windows: [panelWindow]
            onCleared: {
                if (!GlobalStates.isPickingFile) {
                    GlobalStates.quickSettingsOpen = false;
                }
            }
        }

        QuickSettingsContent {
            id: content
            anchors.top: parent.top
            anchors.topMargin: Appearance.sizes.statusBarHeight + 10 * Appearance.effectiveScale
            anchors.horizontalCenter: parent.horizontalCenter
            visible: isActive
            
            // Override visibility logic from the content itself if needed, 
            // but usually content has its own opacity animations.
            opacity: GlobalStates.quickSettingsOpen ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            Connections {
                target: content
                function onClosed() {
                    GlobalStates.quickSettingsOpen = false;
                    GlobalStates.quickSettingsEditMode = false;
                }
            }
        }
    }
}

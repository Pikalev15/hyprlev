import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: islandPanel
            required property var modelData
            screen: modelData

            // Increase implicit size to allow the pill to expand without being clipped
            implicitWidth: 450
            implicitHeight: 400
            color: "transparent"
            exclusiveZone: 0

            WlrLayershell.namespace: "dynamic-island"
            WlrLayershell.layer: WlrLayer.Top
            WlrLayershell.anchors.top: true
            WlrLayershell.anchors.left: true
            WlrLayershell.anchors.right: true

            Pill {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}

// shell.qml — Quickshell entry point
import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            // Tall enough to show tooltips below the island without clipping
            // Island is 28px, tooltip ~30px, gap 4px = need ~70px total
            height: 70
            color: "transparent"

            // Only reserve 42px at top so windows don't go under tooltip area
            exclusiveZone: 42

            WlrLayershell.namespace: "bar"
            WlrLayershell.layer: WlrLayer.Top

            Bar {
                // Pin island to top, let tooltip space exist below
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height
            }
        }
    }
}

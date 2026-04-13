// shell.qml
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
            anchors { top: true; left: true; right: true }
            height: 42
            color: "transparent"
            exclusiveZone: height
            WlrLayershell.namespace: "bar"
            WlrLayershell.layer: WlrLayer.Top

            Bar {
                anchors.fill: parent
                screen: bar.screen
            }
        }
    }
}

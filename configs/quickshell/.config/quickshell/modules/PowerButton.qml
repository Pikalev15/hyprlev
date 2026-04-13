// modules/PowerButton.qml — Power/session icon (rightmost)
import QtQuick
import Quickshell.Io

Item {
    id: root
    width: 20
    height: 20
    property bool hovered: false

    Text {
        anchors.centerIn: parent
        font.pixelSize: 13
        text: "󰐥"   // nf-md-power  (matches the red power icon in screenshot)

        color: root.hovered ? "#ff6b6b" : "#cc4444"
        Behavior on color { ColorAnimation { duration: 100 } }

        scale: root.hovered ? 1.15 : 1.0
        Behavior on scale { NumberAnimation { duration: 120 } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: {
            // Opens wlogout or rofi-power-menu — adjust to taste
            powerProc.command = ["bash", "-c",
                "wlogout --protocol layer-shell &"
            ]
            powerProc.running = true
        }
    }

    Process { id: powerProc }
}

// modules/SettingsButton.qml — Gear icon on left
import QtQuick
import Quickshell.Io

Item {
    width: 20
    height: 20

    property bool hovered: false

    Text {
        anchors.centerIn: parent
        font.pixelSize: 13
        text: "󰒓"   // nf-md-cog  (or "" nf-fa-cog)
        color: parent.hovered ? "#ffffff" : "#aaaaaa"

        Behavior on color { ColorAnimation { duration: 100 } }

        // Slow spin on hover
        rotation: parent.hovered ? 30 : 0
        Behavior on rotation { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: parent.hovered = true
        onExited: parent.hovered = false
        onClicked: {
            settingsProc.command = ["bash", "-c", "rofi -show drun &"]
            settingsProc.running = true
        }
    }

    Process { id: settingsProc }
}

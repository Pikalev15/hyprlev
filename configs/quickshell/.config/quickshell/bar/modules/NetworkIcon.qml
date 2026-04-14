// modules/NetworkIcon.qml — WiFi status via nmcli
import QtQuick
import Quickshell.Io

Item {
    id: root
    width: 18
    height: 20

    property int  strength: 0
    property bool connected: false
    property bool hovered: false

    Process {
        id: nmProc
        command: ["bash", "-c",
            "nmcli -t -f active,signal dev wifi 2>/dev/null | grep '^yes' | head -1"
        ]
        stdout: SplitParser {
            onRead: function(line) {
                var parts = line.split(":")
                if (parts.length >= 2) {
                    root.connected = true
                    root.strength  = parseInt(parts[1]) || 0
                } else {
                    root.connected = false
                    root.strength  = 0
                }
            }
        }
    }
    Timer { interval: 5000; repeat: true; running: true; onTriggered: nmProc.running = true }

    Text {
        anchors.centerIn: parent
        font.pixelSize: 13
        text: !root.connected        ? "󰤭"
            : root.strength >= 75    ? "󰤨"
            : root.strength >= 50    ? "󰤥"
            : root.strength >= 25    ? "󰤢"
            :                          "󰤟"
        color: root.connected ? "#cccccc" : "#666666"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited:  root.hovered = false
    }

    BarTooltip {
        sourceItem: root
        text: root.connected ? "WiFi  " + root.strength + "%" : "Not connected"
        show: root.hovered
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 4
    }
}

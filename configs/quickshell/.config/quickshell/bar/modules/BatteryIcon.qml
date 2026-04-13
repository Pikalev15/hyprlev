// modules/BatteryIcon.qml — Battery via /sys/class/power_supply/BAT0
import QtQuick
import Quickshell.Io

Item {
    id: root
    width: 22
    height: 20

    property int  percent: 100
    property bool charging: false
    property bool full: false
    property bool hovered: false

    Process {
        id: batProc
        command: ["bash", "-c",
            "echo $(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100) " +
            "$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo Unknown)"
        ]
        stdout: SplitParser {
            onRead: function(line) {
                var parts     = line.trim().split(" ")
                root.percent  = parseInt(parts[0]) || 100
                root.charging = parts[1] === "Charging"
                root.full     = parts[1] === "Full"
            }
        }
    }
    Timer { interval: 30000; repeat: true; running: true; onTriggered: batProc.running = true }

    Text {
        anchors.centerIn: parent
        font.pixelSize: 13
        text: root.charging || root.full ? "󰂄"
            : root.percent >= 90  ? "󰁹"
            : root.percent >= 80  ? "󰂂"
            : root.percent >= 70  ? "󰂁"
            : root.percent >= 60  ? "󰂀"
            : root.percent >= 50  ? "󰁿"
            : root.percent >= 40  ? "󰁾"
            : root.percent >= 30  ? "󰁽"
            : root.percent >= 20  ? "󰁼"
            : root.percent >= 10  ? "󰁻"
            :                       "󰁺"
        color: root.percent <= 20 && !root.charging ? "#e05a5a"
             : root.charging                         ? "#71d18b"
             :                                         "#cccccc"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited:  root.hovered = false
    }

    BarTooltip {
        text: root.percent + "% — " + (root.full ? "Full" : root.charging ? "Charging" : "Discharging")
        show: root.hovered
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 4
    }
}

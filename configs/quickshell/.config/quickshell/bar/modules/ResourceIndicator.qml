// modules/ResourceIndicator.qml — CPU+RAM stat (the green "71" in screenshot)
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    width: row.implicitWidth
    height: 20

    property real cpuPercent: 0
    property int  ramUsedMb: 0
    property int  ramTotalMb: 0
    property var  _prevCpu: [0, 0, 0, 0, 0, 0, 0, 0]
    property bool hovered: false

    property real combinedScore: (cpuPercent + (ramTotalMb > 0 ? (ramUsedMb / ramTotalMb) * 100 : 0)) / 2
    property color scoreColor: combinedScore < 50 ? "#71d18b"
                             : combinedScore < 75 ? "#e8c56a"
                             :                      "#e05a5a"

    Process {
        id: cpuProc
        command: ["bash", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: function(line) {
                var parts = line.trim().split(/\s+/).slice(1).map(Number)
                var prev = root._prevCpu
                var idle      = parts[3] + parts[4]
                var total     = parts.reduce(function(a,b){ return a+b }, 0)
                var prevIdle  = prev[3] + prev[4]
                var prevTotal = prev.reduce(function(a,b){ return a+b }, 0)
                var dTotal = total - prevTotal
                var dIdle  = idle  - prevIdle
                root.cpuPercent = dTotal > 0 ? Math.round((1 - dIdle / dTotal) * 100) : 0
                root._prevCpu = parts
            }
        }
    }
    Timer { interval: 2000; repeat: true; running: true; onTriggered: cpuProc.running = true }

    Process {
        id: ramProc
        command: ["bash", "-c", "awk '/MemTotal|MemAvailable/{print $2}' /proc/meminfo"]
        property var lines: []
        stdout: SplitParser {
            onRead: function(line) {
                ramProc.lines.push(parseInt(line))
                if (ramProc.lines.length >= 2) {
                    root.ramTotalMb = Math.round(ramProc.lines[0] / 1024)
                    root.ramUsedMb  = Math.round((ramProc.lines[0] - ramProc.lines[1]) / 1024)
                    ramProc.lines = []
                }
            }
        }
    }
    Timer { interval: 3000; repeat: true; running: true; onTriggered: ramProc.running = true }

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Text {
            text: ""
            font.pixelSize: 11
            color: root.scoreColor
        }
        Text {
            text: Math.round(root.combinedScore)
            font.pixelSize: 12
            font.weight: Font.Medium
            color: root.scoreColor
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited:  root.hovered = false
    }

    BarTooltip {
        sourceItem: root
        text: "CPU: " + Math.round(root.cpuPercent) + "%\nRAM: " + root.ramUsedMb + " / " + root.ramTotalMb + " MB"
        show: root.hovered
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 4
    }
}

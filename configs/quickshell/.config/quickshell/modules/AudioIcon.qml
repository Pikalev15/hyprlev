// modules/AudioIcon.qml — PipeWire volume/mute via wpctl
import QtQuick
import Quickshell.Io

Item {
    id: root
    width: 18
    height: 20

    property real volume: 0.0
    property bool muted: false
    property bool hovered: false

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: function(line) {
                root.muted  = line.includes("[MUTED]")
                var match   = line.match(/Volume:\s+([\d.]+)/)
                root.volume = match ? parseFloat(match[1]) : 0
            }
        }
    }
    Timer { interval: 2000; repeat: true; running: true; onTriggered: volProc.running = true }

    Process { id: volChanger }
    Process { id: muteToggle; onExited: volProc.running = true }

    Text {
        anchors.centerIn: parent
        font.pixelSize: 13
        text: root.muted         ? "󰖁"
            : root.volume >= 0.7 ? "󰕾"
            : root.volume >= 0.3 ? "󰖀"
            :                      "󰕿"
        color: root.muted ? "#888888" : "#cccccc"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited:  root.hovered = false
        onClicked: {
            muteToggle.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
            muteToggle.running = true
        }
        onWheel: function(wheel) {
            var delta = wheel.angleDelta.y > 0 ? "2%+" : "2%-"
            volChanger.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", delta]
            volChanger.running = true
        }
    }

    BarTooltip {
        text: root.muted ? "Muted" : Math.round(root.volume * 100) + "%"
        show: root.hovered
        anchors.bottom: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 4
    }
}

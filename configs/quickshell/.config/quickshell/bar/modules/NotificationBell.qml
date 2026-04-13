// modules/NotificationBell.qml — SwayNC bell + count badge
import QtQuick
import Quickshell.Io

Item {
    id: root
    width: 20
    height: 20

    property int  count: 0
    property bool dnd: false
    property bool hovered: false

    Process {
        id: countProc
        command: ["swaync-client", "--count"]
        stdout: SplitParser {
            onRead: function(line) {
                root.count = parseInt(line.trim()) || 0
            }
        }
    }
    Timer { interval: 3000; repeat: true; running: true; onTriggered: countProc.running = true }

    Process { id: toggleProc }
    Process { id: dndProc; onExited: countProc.running = true }

    Text {
        anchors.centerIn: parent
        font.pixelSize: 13
        text: root.dnd          ? "󰂛"
            : root.count > 0    ? "󰂞"
            :                     "󰂜"
        color: root.hovered       ? "#ffffff"
             : root.count > 0     ? "#e8c56a"
             :                      "#aaaaaa"
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    // Count badge
    Rectangle {
        visible: root.count > 0 && !root.dnd
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 2
        anchors.rightMargin: 1
        width: Math.max(13, badgeText.implicitWidth + 4)
        height: 10
        radius: 5
        color: "#e05a8a"

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: root.count > 99 ? "99+" : root.count
            font.pixelSize: 7
            font.weight: Font.Bold
            color: "#ffffff"
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited:  root.hovered = false
        onClicked: {
            toggleProc.command = ["swaync-client", "--toggle-panel"]
            toggleProc.running = true
        }
        onPressAndHold: {
            dndProc.command = ["swaync-client", "--toggle-dnd"]
            dndProc.running = true
        }
    }
}

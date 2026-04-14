// modules/TrayIcon.qml — Reusable icon-only tray item
import QtQuick

Item {
    id: root
    width: 18
    height: 20

    required property string iconName
    property string tooltip: ""
    property color  iconColor: "#aaaaaa"
    property bool   hovered: false

    Text {
        anchors.centerIn: parent
        font.pixelSize: 13
        text: {
            switch (root.iconName) {
                case "bluetooth-symbolic": return "󰂯"
                case "bluetooth-active":   return "󰂱"
                case "bluetooth-disabled": return "󰂲"
                default:                   return "?"
            }
        }
        color: root.hovered ? "#ffffff" : root.iconColor
        Behavior on color { ColorAnimation { duration: 100 } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited:  root.hovered = false
    }

    BarTooltip {
        sourceItem: root
        text: root.tooltip
        show: root.hovered
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 4
    }
}

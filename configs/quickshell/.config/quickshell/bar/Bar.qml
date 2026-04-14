// Bar.qml — Floating island, pinned to top of taller panel
import QtQuick
import QtQuick.Layouts
import "modules"

Item {
    id: root

    // Island sits at the very top, 42px tall
    Rectangle {
        id: island
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        height: 28
        anchors.topMargin: 7
        width: inner.implicitWidth + 24
        radius: height / 2
        color: Qt.rgba(0.08, 0.08, 0.11, 0.90)

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: Qt.rgba(1, 1, 1, 0.08)
            border.width: 1
        }

        RowLayout {
            id: inner
            anchors.centerIn: parent
            spacing: 10

            SettingsButton {}
            Rectangle { width: 1; height: 14; color: Qt.rgba(1,1,1,0.1) }
            Workspaces {}
            Rectangle { width: 1; height: 14; color: Qt.rgba(1,1,1,0.1) }
            SystemTray {}
            Rectangle { width: 1; height: 14; color: Qt.rgba(1,1,1,0.1) }
            Clock {}
            Rectangle { width: 1; height: 14; color: Qt.rgba(1,1,1,0.1) }
            NotificationBell {}
            PowerButton {}
        }
    }

    // Tooltips render into this layer below the island, never clipped
    Item {
        id: tooltipLayer
        anchors.top: island.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 30
    }
}

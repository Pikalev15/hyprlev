// Bar.qml — Floating island layout
import QtQuick
import QtQuick.Layouts
import "modules"

Item {
    id: root
    required property var screen

    Rectangle {
        id: island
        anchors.centerIn: parent
        height: 28
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
}

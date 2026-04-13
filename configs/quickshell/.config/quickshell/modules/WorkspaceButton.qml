// modules/WorkspaceButton.qml — Single workspace pill/number
import QtQuick
import Quickshell.Hyprland

Item {
    id: root
    required property int wsIndex
    required property bool active
    required property bool occupied

    width: active ? pill.implicitWidth + 14 : 20
    height: 20

    Behavior on width {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    Rectangle {
        id: pill
        anchors.centerIn: parent
        width: parent.width
        height: 20
        radius: 10

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root.active ? "#e05a8a" : "transparent" }
            GradientStop { position: 1.0; color: root.active ? "#c4447a" : "transparent" }
        }

        opacity: root.active ? 1.0 : (root.occupied ? 0.9 : 0.5)
        Behavior on opacity { NumberAnimation { duration: 120 } }

        Text {
            id: label
            anchors.centerIn: parent
            text: root.wsIndex
            font.pixelSize: 12
            font.weight: root.active ? Font.Medium : Font.Normal
            color: root.active    ? "#ffffff"
                 : root.occupied  ? "#cccccc"
                 :                  "#666666"
        }
    }

    // Dot under occupied (non-active) workspaces
    Rectangle {
        visible: root.occupied && !root.active
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 1
        width: 3; height: 3; radius: 2
        color: "#e05a8a"
        opacity: 0.8
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch("workspace " + root.wsIndex)
    }
}

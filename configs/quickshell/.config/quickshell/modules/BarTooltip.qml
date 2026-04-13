// modules/BarTooltip.qml — Lightweight tooltip, no QtQuick.Controls needed
import QtQuick

Rectangle {
    id: tip
    required property string text
    required property bool show

    visible: show && text !== ""
    // Position above parent — caller anchors this as needed
    z: 999

    color: "#1e1e24"
    border.color: Qt.rgba(1,1,1,0.12)
    border.width: 1
    radius: 5
    width: label.implicitWidth + 12
    height: label.implicitHeight + 8

    Text {
        id: label
        anchors.centerIn: parent
        text: tip.text
        font.pixelSize: 11
        color: "#dddddd"
    }
}

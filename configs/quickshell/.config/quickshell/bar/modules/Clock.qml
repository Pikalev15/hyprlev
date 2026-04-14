// modules/Clock.qml — Live clock (12hr format matching screenshot)
import QtQuick

Item {
    id: root
    width: timeLabel.implicitWidth
    height: 20

    property bool use12hr: true
    property bool hovered: false

    function formatTime() {
        var d = new Date()
        var h = d.getHours()
        var m = d.getMinutes()
        var ampm = ""
        if (root.use12hr) {
            ampm = h >= 12 ? " PM" : " AM"
            h = h % 12 || 12
        }
        return h + ":" + (m < 10 ? "0" : "") + m + ampm
    }

    Text {
        id: timeLabel
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 12
        font.weight: Font.Medium
        color: "#e0e0e0"
        text: root.formatTime()

        Timer {
            interval: 1000
            repeat: true
            running: true
            onTriggered: timeLabel.text = root.formatTime()
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
        text: Qt.formatDate(new Date(), "dddd, MMMM d yyyy")
        show: root.hovered
        anchors.top: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 4
    }
}

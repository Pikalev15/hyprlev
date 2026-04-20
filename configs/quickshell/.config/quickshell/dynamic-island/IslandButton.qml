import QtQuick

Rectangle {
    id: button
    implicitWidth: 80
    implicitHeight: 30
    color: "#333"
    radius: 8
    property alias text: label.text
    signal clicked

    Text {
        id: label
        anchors.centerIn: parent
        color: "white"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: button.clicked()
    }
}

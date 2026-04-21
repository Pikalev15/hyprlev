import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var island

    Item {
        anchors.fill: parent
        anchors.margins: island.s(28)
        anchors.bottomMargin: island.s(72)

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width
            spacing: island.s(12)

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: island.timeStrSec
                font.family: "JetBrains Mono"; font.pixelSize: island.s(50); font.weight: Font.Black
                color: island.text
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: island.dateStr
                font.family: "JetBrains Mono"; font.pixelSize: island.s(15); font.weight: Font.Medium
                color: island.subtext0
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: island.s(4); Layout.bottomMargin: island.s(4)
                height: 1
                color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.08)
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: island.s(14)

                Text {
                    text: island.weatherIcon || "󰖔"
                    font.family: "Iosevka Nerd Font"; font.pixelSize: island.s(36)
                    color: island.mauve
                }
                ColumnLayout {
                    spacing: island.s(2)
                    Text {
                        text: island.weatherTemp
                        font.family: "JetBrains Mono"; font.pixelSize: island.s(24); font.weight: Font.Black
                        color: island.peach
                    }
                    Text {
                        text: island.weatherTemp === "--°" ? "No data" : "Weather now"
                        font.family: "JetBrains Mono"; font.pixelSize: island.s(11)
                        color: island.subtext0
                    }
                }
            }
        }
    }
}

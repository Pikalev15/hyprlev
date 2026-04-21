import QtQuick
import QtQuick.Layouts

Item {
    property var island

    ColumnLayout {
        anchors.centerIn: parent
        spacing: island.s(10)

        // Big pulsing mic
        Item {
            Layout.alignment: Qt.AlignHCenter
            width: island.s(64); height: island.s(64)

            Rectangle {
                anchors.centerIn: parent
                width: island.s(64); height: island.s(64); radius: island.s(32)
                color: Qt.rgba(island.green.r, island.green.g, island.green.b, 0.1)
                SequentialAnimation on scale {
                    running: island.discordInCall; loops: Animation.Infinite
                    NumberAnimation { to: 1.12; duration: 900; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0;  duration: 900; easing.type: Easing.InOutSine }
                }
            }
            Text {
                anchors.centerIn: parent; text: "󰍬"
                font.family: "Iosevka Nerd Font"; font.pixelSize: island.s(32)
                color: island.green
            }
        }

        // Timer
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: {
                let t = island.discordCallSeconds
                let h = Math.floor(t / 3600)
                let m = Math.floor((t % 3600) / 60)
                let s2 = t % 60
                if (h > 0)
                    return (h < 10 ? "0"+h : h) + ":" + (m < 10 ? "0"+m : m) + ":" + (s2 < 10 ? "0"+s2 : s2)
                return (m < 10 ? "0"+m : m) + ":" + (s2 < 10 ? "0"+s2 : s2)
            }
            font.family: "JetBrains Mono"; font.pixelSize: island.s(28); font.weight: Font.Black
            color: island.green
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Voice Call · Discord"
            font.family: "JetBrains Mono"; font.pixelSize: island.s(11)
            color: island.subtext0
        }

        // Mute toggle
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: island.s(120); height: island.s(36); radius: island.s(18)
            color: muteHover.containsMouse
                ? Qt.rgba(island.red.r, island.red.g, island.red.b, 0.22)
                : Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.6)
            Behavior on color { ColorAnimation { duration: 150 } }

            Row {
                anchors.centerIn: parent; spacing: island.s(6)
                Text {
                    text: "󰍭"; font.family: "Iosevka Nerd Font"; font.pixelSize: island.s(16)
                    color: island.subtext0; anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: "Mute mic"; font.family: "JetBrains Mono"
                    font.pixelSize: island.s(12); font.weight: Font.Bold
                    color: island.subtext0; anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: muteHover; anchors.fill: parent; hoverEnabled: true
                onClicked: island.exec("wpctl set-mute @DEFAULT_SOURCE@ toggle")
            }
        }
    }
}

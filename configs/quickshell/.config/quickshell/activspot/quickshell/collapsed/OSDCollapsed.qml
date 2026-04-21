import QtQuick
import QtQuick.Layouts

Item {
    property var island

    property int preferredWidth: {
        if (island.osdType === "layout") return island.s(160)
        return island.s(190)
    }

    anchors.centerIn: parent
    width: preferredWidth
    height: island.s(48)

    // Layout
    Row {
        visible: island.osdType === "layout"
        anchors.centerIn: parent
        spacing: island.s(8)

        Text {
            text: "⌨"
            font.pixelSize: island.s(16)
            color: island.teal
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: island.osdValue
            font.family: "JetBrains Mono"; font.pixelSize: island.s(15); font.weight: Font.Black
            color: island.teal
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Volume / Brightness
    Column {
        visible: island.osdType === "volume" || island.osdType === "brightness"
        anchors.centerIn: parent
        spacing: island.s(5)

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: island.s(8)

            Text {
                text: {
                    if (island.osdType === "volume") {
                        let v = parseInt(island.osdValue) || 0
                        if (v === 0) return "󰖁"
                        if (v < 40) return "󰖀"
                        return "󰕾"
                    }
                    let b = parseInt(island.osdValue) || 0
                    if (b < 30) return "󰃞"
                    if (b < 70) return "󰃟"
                    return "󰃠"
                }
                font.family: "Iosevka Nerd Font"; font.pixelSize: island.s(18)
                color: island.osdType === "volume" ? island.blue : island.peach
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: (parseInt(island.osdValue) || 0) + "%"
                font.family: "JetBrains Mono"; font.pixelSize: island.s(15); font.weight: Font.Black
                color: island.osdType === "volume" ? island.blue : island.peach
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: island.s(130); height: island.s(3); radius: island.s(2)
            anchors.horizontalCenter: parent.horizontalCenter
            color: Qt.rgba(island.surface1.r, island.surface1.g, island.surface1.b, 0.35)

            Rectangle {
                anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                width: parent.width * Math.max(0, Math.min(1, (parseInt(island.osdValue) || 0) / 100))
                radius: parent.radius
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: island.osdType === "volume" ? island.blue  : island.peach }
                    GradientStop { position: 1.0; color: island.osdType === "volume" ? island.mauve : island.yellow }
                }
                Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
            }
        }
    }
}

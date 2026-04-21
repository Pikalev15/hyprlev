import QtQuick
import QtQuick.Layouts
import "../pet"

Row {
    property var island
    property int preferredWidth: island.s(300)
    spacing: island.s(14)

    ColumnLayout {
        spacing: -2; anchors.verticalCenter: parent.verticalCenter
        Text { text: island.timeStr; font.family: "JetBrains Mono"; font.pixelSize: island.s(16); font.weight: Font.Black; color: island.blue }
        Text { text: island.dateStr; font.family: "JetBrains Mono"; font.pixelSize: island.s(11); font.weight: Font.Bold; color: island.subtext0 }
    }

    Column {
        spacing: island.s(1); anchors.verticalCenter: parent.verticalCenter

        Row {
            spacing: island.s(6); anchors.horizontalCenter: parent.horizontalCenter
            Text { text: island.weatherIcon; visible: island.weatherIcon !== ""; font.family: "Iosevka Nerd Font"; font.pixelSize: island.s(20); color: island.mauve }
            Text { text: island.weatherTemp; visible: island.weatherTemp !== "--°"; font.family: "JetBrains Mono"; font.pixelSize: island.s(14); font.weight: Font.Black; color: island.peach }
        }

        // VPN lock — snap-shut animation, shown under temperature
        Item {
            id: lockItem
            width: parent.width; height: island.s(14)
            visible: opacity > 0.001
            opacity: island.vpnActive ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

            property bool _lockClosed: false
            property bool _vpn: island ? island.vpnActive : false

            on_VpnChanged: {
                if (_vpn) {
                    _lockClosed = false;
                    lockSnapAnim.restart();
                } else {
                    _lockClosed = false;
                }
            }

            SequentialAnimation {
                id: lockSnapAnim
                NumberAnimation { target: lockIcon; property: "scale"; to: 0.0; duration: 90; easing.type: Easing.InCubic }
                ScriptAction    { script: lockItem._lockClosed = true }
                NumberAnimation { target: lockIcon; property: "scale"; to: 1.18; duration: 160; easing.type: Easing.OutBack }
                NumberAnimation { target: lockIcon; property: "scale"; to: 1.0;  duration: 100; easing.type: Easing.InOutQuad }
            }

            Text {
                id: lockIcon
                anchors.centerIn: parent
                text: lockItem._lockClosed ? "󰒃" : "󰒄"
                font.family: "Iosevka Nerd Font"; font.pixelSize: island.s(11)
                color: island.green
            }
        }
    }

    CatPill {
        width: island.s(24); height: island.s(24); anchors.verticalCenter: parent.verticalCenter
        playing: island.musicData.status === "Playing"
        notifActive: island.notifActive || island.notifBadgeVisible
        showQuestion: false
        catColor: island.text; eyeColor: island.base
    }
}

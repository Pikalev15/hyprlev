import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: root
    property var island

    Item {
        anchors.fill: parent
        anchors.margins: island.s(24)
        anchors.bottomMargin: island.s(72)

        ColumnLayout {
            anchors.fill: parent
            spacing: island.s(16)

            // ── Cover art + track info ──────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: island.s(20)

                Rectangle {
                    Layout.preferredWidth: island.s(110); Layout.preferredHeight: island.s(110)
                    radius: island.s(14); color: island.surface0; clip: true; layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true; shadowColor: "#000000"
                        shadowOpacity: 0.45; shadowBlur: 0.6; shadowVerticalOffset: 3
                    }
                    Image {
                        anchors.fill: parent; anchors.margins: 1
                        source: island.musicData.artUrl || ""
                        fillMode: Image.PreserveAspectCrop; asynchronous: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
                    spacing: island.s(4)

                    Text {
                        text: island.musicData.title || "Unknown"
                        font.family: "JetBrains Mono"; font.pixelSize: island.s(20); font.weight: Font.Black
                        color: island.text; elide: Text.ElideRight; Layout.fillWidth: true
                    }
                    Text {
                        text: island.musicData.artist || "—"
                        font.family: "JetBrains Mono"; font.pixelSize: island.s(13)
                        color: island.subtext0; elide: Text.ElideRight; Layout.fillWidth: true
                    }
                    Item { Layout.fillHeight: true }

                    Slider {
                        id: prog
                        Layout.fillWidth: true; Layout.preferredHeight: island.s(16)
                        from: 0; to: 100; value: island.musicData.percent || 0
                        onMoved: {
                            island.userIsSeeking = true
                            island.exec(`~/.config/hypr/scripts/quickshell/music/player_control.sh seek ${value} ${island.musicData.length} "${island.musicData.playerName}"`)
                        }
                        onPressedChanged: if (!pressed) island.userIsSeeking = false

                        background: Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width; height: island.s(4); radius: island.s(2)
                            color: island.surface0
                            Rectangle {
                                width: prog.visualPosition * parent.width; height: parent.height; radius: island.s(2)
                                gradient: Gradient {
                                    orientation: Gradient.Horizontal
                                    GradientStop { position: 0.0; color: island.mauve }
                                    GradientStop { position: 1.0; color: island.blue }
                                }
                            }
                        }
                        handle: Rectangle {
                            x: prog.visualPosition * (prog.width - island.s(12))
                            y: (prog.height - island.s(12)) / 2
                            width: island.s(12); height: island.s(12); radius: island.s(6)
                            color: island.text; border.width: 2; border.color: island.mauve
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: island.musicData.positionStr || "00:00"; font.family: "JetBrains Mono"; font.pixelSize: island.s(10); color: island.subtext0 }
                        Item { Layout.fillWidth: true }
                        Text { text: island.musicData.lengthStr || "00:00"; font.family: "JetBrains Mono"; font.pixelSize: island.s(10); color: island.subtext0 }
                    }
                }
            }

            // ── Playback controls ───────────────────────────────
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: island.s(32)

                Rectangle {
                    Layout.preferredWidth: island.s(44); Layout.preferredHeight: island.s(44); radius: island.s(22)
                    color: prevMouse.containsMouse ? island.surface1 : Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.6)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Text { anchors.centerIn: parent; text: "󰒮"; font.family: "Iosevka Nerd Font"; font.pixelSize: island.s(22); color: island.text }
                    MouseArea { id: prevMouse; anchors.fill: parent; hoverEnabled: true; onClicked: island.exec("playerctl previous") }
                }

                Rectangle {
                    Layout.preferredWidth: island.s(60); Layout.preferredHeight: island.s(60); radius: island.s(30)
                    color: island.mauve
                    scale: playMouse.containsMouse ? 1.06 : 1.0
                    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                    layer.enabled: true
                    layer.effect: MultiEffect { shadowEnabled: true; shadowColor: island.mauve; shadowOpacity: 0.4; shadowBlur: 0.8 }
                    Text { anchors.centerIn: parent; text: island.musicData.status === "Playing" ? "󰏤" : "󰐊"; font.family: "Iosevka Nerd Font"; font.pixelSize: island.s(28); color: island.base }
                    MouseArea { id: playMouse; anchors.fill: parent; hoverEnabled: true; onClicked: island.exec("playerctl play-pause") }
                }

                Rectangle {
                    Layout.preferredWidth: island.s(44); Layout.preferredHeight: island.s(44); radius: island.s(22)
                    color: nextMouse.containsMouse ? island.surface1 : Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.6)
                    Behavior on color { ColorAnimation { duration: 180 } }
                    Text { anchors.centerIn: parent; text: "󰒭"; font.family: "Iosevka Nerd Font"; font.pixelSize: island.s(22); color: island.text }
                    MouseArea { id: nextMouse; anchors.fill: parent; hoverEnabled: true; onClicked: island.exec("playerctl next") }
                }
            }

            // ── EQ header + preset badge ────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "EQUALIZER"
                    font.family: "JetBrains Mono"; font.pixelSize: island.s(11); font.weight: Font.Black; font.letterSpacing: 2
                    color: island.mauve; Layout.fillWidth: true
                }
                Rectangle {
                    Layout.preferredHeight: island.s(20)
                    Layout.preferredWidth: presetLabel.implicitWidth + island.s(16)
                    radius: island.s(10)
                    color: Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.15)
                    border.width: 1; border.color: Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.4)
                    Text {
                        id: presetLabel; anchors.centerIn: parent
                        text: island.eqData.preset || "Flat"
                        font.family: "JetBrains Mono"; font.pixelSize: island.s(10); font.weight: Font.Bold
                        color: island.mauve
                    }
                }
            }

            // ── EQ band sliders ─────────────────────────────────
            RowLayout {
                Layout.fillWidth: true; Layout.preferredHeight: island.s(130)
                spacing: island.s(8)
                Repeater {
                    model: 10
                    delegate: ColumnLayout {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        spacing: island.s(3)

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: { let v = island.eqData["b" + (index + 1)] || 0; return v > 0 ? "+" + v : "" + v }
                            font.family: "JetBrains Mono"; font.pixelSize: island.s(8)
                            color: Math.abs(island.eqData["b" + (index + 1)] || 0) > 0 ? island.mauve : island.subtext0
                        }
                        Item {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            Slider {
                                id: eqSlider; anchors.fill: parent; orientation: Qt.Vertical
                                from: -12; to: 12; stepSize: 1
                                value: island.eqData["b" + (index + 1)] || 0
                                onMoved: island.exec(`~/.config/hypr/scripts/quickshell/music/equalizer.sh set_band ${index + 1} ${value}`)
                                onPressedChanged: if (!pressed) island.exec(`~/.config/hypr/scripts/quickshell/music/equalizer.sh apply`)

                                background: Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: island.s(5); height: parent.height; radius: island.s(2)
                                    color: island.surface0
                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: island.s(10); height: 1
                                        color: Qt.rgba(island.text.r, island.text.g, island.text.b, 0.15)
                                    }
                                    Rectangle {
                                        property real valNorm: (eqSlider.value - eqSlider.from) / (eqSlider.to - eqSlider.from)
                                        property real centerY: parent.height / 2
                                        property real fillTop:    Math.min(centerY, parent.height * (1 - valNorm))
                                        property real fillBottom: Math.max(centerY, parent.height * (1 - valNorm))
                                        x: (parent.width - width) / 2; y: fillTop
                                        width: parent.width; height: fillBottom - fillTop; radius: island.s(2)
                                        gradient: Gradient {
                                            orientation: Gradient.Vertical
                                            GradientStop { position: 0.0; color: island.mauve }
                                            GradientStop { position: 1.0; color: island.blue }
                                        }
                                        opacity: Math.abs(eqSlider.value) > 0 ? 0.9 : 0.4
                                        Behavior on opacity { NumberAnimation { duration: 200 } }
                                    }
                                }
                                handle: Rectangle {
                                    x: (parent.width - island.s(13)) / 2
                                    y: eqSlider.visualPosition * (parent.height - island.s(13))
                                    width: island.s(13); height: island.s(13); radius: island.s(6)
                                    color: island.text; border.width: 2; border.color: island.mauve
                                }
                            }
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: ["32","64","125","250","500","1K","2K","4K","8K","16K"][index]
                            font.family: "JetBrains Mono"; font.pixelSize: island.s(8)
                            color: island.subtext0
                        }
                    }
                }
            }

            // ── EQ preset chips ─────────────────────────────────
            RowLayout {
                Layout.fillWidth: true; spacing: island.s(6)
                Repeater {
                    model: ["Flat", "Bass", "Treble", "Vocal", "Pop", "Rock"]
                    delegate: Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: island.s(28); radius: island.s(14)
                        property bool isActive:  island.eqData.preset === modelData
                        property bool isHovered: chipMouse.containsMouse
                        color: isActive ? island.mauve
                             : (isHovered ? island.surface1
                             : Qt.rgba(island.surface0.r, island.surface0.g, island.surface0.b, 0.6))
                        Behavior on color { ColorAnimation { duration: 180 } }
                        border.width: 1
                        border.color: isActive
                            ? Qt.rgba(island.mauve.r, island.mauve.g, island.mauve.b, 0.8)
                            : Qt.rgba(island.text.r, island.text.g, island.text.b, 0.08)
                        Text {
                            anchors.centerIn: parent; text: modelData
                            font.family: "JetBrains Mono"; font.pixelSize: island.s(10); font.weight: Font.Bold
                            color: parent.isActive ? island.base : island.text
                        }
                        MouseArea {
                            id: chipMouse; anchors.fill: parent; hoverEnabled: true
                            onClicked: island.exec(`~/.config/hypr/scripts/quickshell/music/equalizer.sh preset ${modelData}`)
                        }
                    }
                }
            }
        }
    }
}

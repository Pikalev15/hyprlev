import "../../core"
import "../../core/functions" as Functions
import "../../widgets"
import "../../services"
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Item {
    id: musicRoot

    // Design-straight data polling (to get 'blur' from music_info.sh)
    property var musicData: ({
        "title": "Loading...", "artist": "", "status": "Stopped", "percent": 0,
        "lengthStr": "00:00", "positionStr": "00:00", "artUrl": "", "playerName": "",
        "blur": ""
    })

    Process {
        id: musicProc
        command: ["bash", "-c", "~/.config/hypr/scripts/quickshell/music/music_info.sh"]
        running: GlobalStates.dashboardOpen
        stdout: StdioCollector {
            onStreamFinished: { try { if (this.text) musicRoot.musicData = JSON.parse(this.text); } catch(e) {} }
        }
    }
    
    Timer { 
        interval: 800; running: GlobalStates.dashboardOpen; repeat: true; triggeredOnStart: true
        onTriggered: musicProc.running = true 
    }

    // Equalizer State (Matches MusicPopup exactly)
    property var eqData: ({ "preset": "Flat", "b1":0,"b2":0,"b3":0,"b4":0,"b5":0,"b6":0,"b7":0,"b8":0,"b9":0,"b10":0 })
    Process {
        id: eqGetProc
        command: ["bash", "-c", "$HOME/.config/hypr/scripts/quickshell/music/equalizer.sh get"]
        running: GlobalStates.dashboardOpen
        stdout: StdioCollector {
            onStreamFinished: { try { if (this.text) musicRoot.eqData = JSON.parse(this.text); } catch(e) {} }
        }
    }
    Timer { 
        interval: 1500; running: GlobalStates.dashboardOpen; repeat: true; triggeredOnStart: true
        onTriggered: eqGetProc.running = true 
    }

    function exec(cmd) { Quickshell.execDetached(["bash", "-c", cmd]); }

    // --- UI Structure straight from MusicPopup.qml ---
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Appearance.m3colors.m3surface.r, Appearance.m3colors.m3surface.g, Appearance.m3colors.m3surface.b, 0.95)
        radius: 20 * Appearance.effectiveScale
        border.color: Functions.ColorUtils.applyAlpha(Appearance.m3colors.m3onSurface, 0.1)
        border.width: 1
        clip: true

        // Minimalist Background Blur
        Image {
            anchors.fill: parent
            source: musicRoot.musicData.blur || ""
            fillMode: Image.PreserveAspectCrop
            opacity: 0.15
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 35 * Appearance.effectiveScale
            spacing: 30 * Appearance.effectiveScale

            // Header Row
            RowLayout {
                spacing: 30 * Appearance.effectiveScale
                
                // Cover Art
                Rectangle {
                    width: 160 * Appearance.effectiveScale
                    height: 160 * Appearance.effectiveScale
                    radius: 16 * Appearance.effectiveScale
                    color: Appearance.colors.colLayer2
                    layer.enabled: true
                    layer.effect: MultiEffect { shadowEnabled: true; shadowColor: "#000000"; shadowOpacity: 0.3; shadowBlur: 0.5 }

                    Rectangle {
                        anchors.fill: parent; anchors.margins: 1; 
                        radius: 15 * Appearance.effectiveScale
                        clip: true
                        Image {
                            anchors.fill: parent
                            source: musicRoot.musicData.artUrl || ""
                            fillMode: Image.PreserveAspectCrop
                            opacity: status === Image.Ready ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 500 } }
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 5 * Appearance.effectiveScale
                    
                    Text {
                        text: musicRoot.musicData.title; font.family: "JetBrains Mono"; 
                        font.pixelSize: 20 * Appearance.effectiveScale; font.weight: Font.Black; 
                        color: Appearance.colors.colOnLayer0
                        elide: Text.ElideRight; Layout.fillWidth: true
                    }
                    Text {
                        text: musicRoot.musicData.artist; font.family: "JetBrains Mono"; 
                        font.pixelSize: 14 * Appearance.effectiveScale; 
                        color: Appearance.colors.colSubtext
                    }

                    // Progress Slider
                    ColumnLayout {
                        Layout.fillWidth: true; Layout.topMargin: 20 * Appearance.effectiveScale; spacing: 2 * Appearance.effectiveScale
                        Slider {
                            id: prog; Layout.fillWidth: true; from: 0; to: 100; value: musicRoot.musicData.percent
                            onMoved: { exec(`~/.config/hypr/scripts/quickshell/music/player_control.sh seek ${value} ${musicRoot.musicData.length} "${musicRoot.musicData.playerName}"`); }
                            background: Rectangle { 
                                height: 4 * Appearance.effectiveScale; radius: 2 * Appearance.effectiveScale; color: Appearance.colors.colLayer2; 
                                Rectangle { width: prog.visualPosition * parent.width; height: 4 * Appearance.effectiveScale; color: Appearance.colors.colPrimary; radius: 2 * Appearance.effectiveScale } 
                            }
                            handle: Rectangle { x: prog.visualPosition * (prog.width-12*Appearance.effectiveScale); y: (prog.height-12*Appearance.effectiveScale)/2; width: 12 * Appearance.effectiveScale; height: 12 * Appearance.effectiveScale; radius: 6 * Appearance.effectiveScale; color: Appearance.colors.colOnLayer0 }
                        }
                        RowLayout {
                            Text { text: musicRoot.musicData.positionStr; font.family: "JetBrains Mono"; font.pixelSize: 10 * Appearance.effectiveScale; color: Appearance.colors.colSubtext }
                            Item { Layout.fillWidth: true }
                            Text { text: musicRoot.musicData.lengthStr; font.family: "JetBrains Mono"; font.pixelSize: 10 * Appearance.effectiveScale; color: Appearance.colors.colSubtext }
                        }
                    }
                }
            }

            // Controls
            RowLayout {
                Layout.alignment: Qt.AlignHCenter; spacing: 50 * Appearance.effectiveScale
                Text { text: "󰒮"; font.family: "Iosevka Nerd Font"; font.pixelSize: 28 * Appearance.effectiveScale; color: Appearance.colors.colOnLayer0; MouseArea { anchors.fill: parent; onClicked: MprisController.previous() } }
                Rectangle {
                    width: 60 * Appearance.effectiveScale; height: 60 * Appearance.effectiveScale; radius: 30 * Appearance.effectiveScale; color: Appearance.colors.colPrimary
                    Text { anchors.centerIn: parent; text: MprisController.isPlaying ? "󰏤" : "󰐊"; font.family: "Iosevka Nerd Font"; font.pixelSize: 32 * Appearance.effectiveScale; color: Appearance.colors.colOnPrimary }
                    MouseArea { anchors.fill: parent; onClicked: MprisController.togglePlaying() }
                }
                Text { text: "󰒭"; font.family: "Iosevka Nerd Font"; font.pixelSize: 28 * Appearance.effectiveScale; color: Appearance.colors.colOnLayer0; MouseArea { anchors.fill: parent; onClicked: MprisController.next() } }
            }

            // Minimalist Equalizer
            ColumnLayout {
                Layout.fillWidth: true; spacing: 15 * Appearance.effectiveScale
                
                RowLayout {
                    Text { text: "Audio Equalizer"; font.family: "JetBrains Mono"; font.pixelSize: 14 * Appearance.effectiveScale; font.bold: true; color: Appearance.colors.colPrimary; Layout.fillWidth: true }
                    Text { text: musicRoot.eqData.preset; font.family: "JetBrains Mono"; font.pixelSize: 12 * Appearance.effectiveScale; color: Appearance.colors.colSubtext }
                }

                Row {
                    Layout.fillWidth: true; height: 120 * Appearance.effectiveScale; spacing: 12 * Appearance.effectiveScale
                    Repeater {
                        model: 10
                        delegate: Item {
                            width: (parent.width - (9 * 12 * Appearance.effectiveScale)) / 10; height: parent.height
                            Slider {
                                id: eq; anchors.fill: parent; orientation: Qt.Vertical; from: -12; to: 12; stepSize: 1; value: musicRoot.eqData["b"+(index+1)] || 0
                                onMoved: exec(`$HOME/.config/hypr/scripts/quickshell/music/equalizer.sh set_band ${index+1} ${Math.round(value)}`)
                                background: Rectangle { anchors.centerIn: parent; width: 6 * Appearance.effectiveScale; height: parent.height; radius: 3 * Appearance.effectiveScale; color: Appearance.colors.colLayer2 }
                                handle: Rectangle { x: (parent.width-12*Appearance.effectiveScale)/2; y: eq.visualPosition * (parent.height-12*Appearance.effectiveScale); width: 12 * Appearance.effectiveScale; height: 12 * Appearance.effectiveScale; radius: 6 * Appearance.effectiveScale; color: Appearance.colors.colPrimary }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 10 * Appearance.effectiveScale
                    Repeater {
                        model: ["Flat", "Bass", "Treble", "Rock", "Pop"]
                        delegate: Rectangle {
                            Layout.fillWidth: true; height: 32 * Appearance.effectiveScale; radius: 8 * Appearance.effectiveScale; color: musicRoot.eqData.preset === modelData ? Appearance.colors.colPrimary : Appearance.colors.colLayer2
                            Text { anchors.centerIn: parent; text: modelData; font.family: "JetBrains Mono"; font.pixelSize: 11 * Appearance.effectiveScale; color: musicRoot.eqData.preset === modelData ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer0 }
                            MouseArea { anchors.fill: parent; onClicked: exec(`$HOME/.config/hypr/scripts/quickshell/music/equalizer.sh preset ${modelData}`) }
                        }
                    }
                }
            }        }
    }
}

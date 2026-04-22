import "../core"
import "../core/functions" as Functions
import "../services"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

/**
 * Pill-style music widget adapted from activspot's MusicCollapsed.qml.
 */
Rectangle {
    id: root
    implicitWidth: 400 * Appearance.effectiveScale
    implicitHeight: 64 * Appearance.effectiveScale
    radius: height / 2
    color: MprisController.dynLayer0
    clip: true
    
    // MD3 Outline Style
    border.width: 1
    border.color: Functions.ColorUtils.applyAlpha(MprisController.dynOnLayer0, 0.12)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12 * Appearance.effectiveScale
        anchors.rightMargin: 12 * Appearance.effectiveScale
        spacing: 12 * Appearance.effectiveScale

        // Cover art
        Rectangle {
            Layout.preferredWidth: 40 * Appearance.effectiveScale
            Layout.preferredHeight: 40 * Appearance.effectiveScale
            radius: 8 * Appearance.effectiveScale
            clip: true
            color: MprisController.dynSecondaryContainer
            
            Image {
                anchors.fill: parent
                source: MprisController.displayedArtFilePath || ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
            }
            
            MaterialSymbol {
                anchors.centerIn: parent
                text: "music_note"
                iconSize: 20 * Appearance.effectiveScale
                color: MprisController.dynOnSecondaryContainer
                visible: !MprisController._artDownloaded || MprisController.displayedArtFilePath === ""
            }
        }

        // Title + artist
        ColumnLayout {
            Layout.fillWidth: true
            spacing: -2 * Appearance.effectiveScale
            
            StyledText {
                text: MprisController.trackTitle
                font.pixelSize: 14 * Appearance.effectiveScale
                font.weight: Font.Bold
                color: MprisController.dynOnLayer0
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            
            StyledText {
                text: MprisController.trackArtist
                font.pixelSize: 11 * Appearance.effectiveScale
                color: MprisController.dynSubtext
                elide: Text.ElideRight
                Layout.fillWidth: true
                visible: text !== ""
            }
        }

        // Playback controls
        Row {
            spacing: 4 * Appearance.effectiveScale
            
            RippleButton {
                implicitWidth: 32 * Appearance.effectiveScale
                implicitHeight: 32 * Appearance.effectiveScale
                buttonRadius: 16 * Appearance.effectiveScale
                colBackground: "transparent"
                onClicked: MprisController.previous()
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "skip_previous"
                    iconSize: 20 * Appearance.effectiveScale
                    color: MprisController.dynOnLayer0
                }
            }
            
            RippleButton {
                implicitWidth: 36 * Appearance.effectiveScale
                implicitHeight: 36 * Appearance.effectiveScale
                buttonRadius: 18 * Appearance.effectiveScale
                colBackground: MprisController.dynPrimary
                colRipple: MprisController.dynPrimaryActive
                onClicked: MprisController.togglePlaying()
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: MprisController.isPlaying ? "pause" : "play_arrow"
                    iconSize: 24 * Appearance.effectiveScale
                    color: MprisController.dynOnPrimary
                    fill: 1
                }
            }
            
            RippleButton {
                implicitWidth: 32 * Appearance.effectiveScale
                implicitHeight: 32 * Appearance.effectiveScale
                buttonRadius: 16 * Appearance.effectiveScale
                colBackground: "transparent"
                onClicked: MprisController.next()
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: "skip_next"
                    iconSize: 20 * Appearance.effectiveScale
                    color: MprisController.dynOnLayer0
                }
            }
        }

        // Cava bars
        Item {
            Layout.preferredWidth: 32 * Appearance.effectiveScale
            Layout.preferredHeight: 24 * Appearance.effectiveScale
            
            Row {
                anchors.centerIn: parent
                spacing: 2 * Appearance.effectiveScale
                
                Repeater {
                    model: 4
                    Rectangle {
                        width: 4 * Appearance.effectiveScale
                        height: {
                            let val = CavaService.values[index * 8] || 0;
                            return Math.max(4 * Appearance.effectiveScale, (val / 1000) * 20 * Appearance.effectiveScale);
                        }
                        anchors.bottom: parent.bottom
                        radius: 2 * Appearance.effectiveScale
                        color: MprisController.dynPrimary
                        opacity: MprisController.isPlaying ? 1.0 : 0.4
                        Behavior on height { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }
    }
}

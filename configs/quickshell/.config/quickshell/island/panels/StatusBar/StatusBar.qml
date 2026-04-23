import "../../core"
import "../../core/functions" as Functions
import "../../services"
import "../../widgets"
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    Variants {
        model: Quickshell.screens
        delegate: PanelWindow {
            id: barWindow
            required property var modelData
            
            screen: modelData
            
            exclusiveZone: Appearance.sizes.statusBarHeight
            WlrLayershell.namespace: "island:statusbar"
            WlrLayershell.layer: WlrLayer.Top

            anchors {
                left: true
                right: true
                top: true
            }

            color: "transparent"
            implicitHeight: Appearance.sizes.statusBarHeight + 20 * Appearance.effectiveScale

            Rectangle {
                id: islandPill
                anchors.centerIn: parent
                width: 225 * Appearance.effectiveScale
                height: Appearance.sizes.statusBarHeight
                color: "black"
                radius: height / 2
                
                // Replace MusicHoverMenu trigger with MediaNotchPopup trigger logic
                Timer {
                    id: musicMenuDelayTimer
                    interval: 300
                    onTriggered: {
                        if (!GlobalStates.islandHovered) GlobalStates.musicMenuOpen = false;
                    }
                }

                Connections {
                    target: GlobalStates
                    function onIslandHoveredChanged() {
                        if (GlobalStates.islandHovered) {
                            musicMenuDelayTimer.stop();
                            if (MprisController.isPlaying) GlobalStates.musicMenuOpen = true;
                        } else {
                            musicMenuDelayTimer.start();
                        }
                    }
                }

                MouseArea {
                    id: islandMa
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: GlobalStates.islandHovered = true
                    onExited: GlobalStates.islandHovered = false
                }
                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Left Click Area -> Quick Settings
                    MouseArea {
                        Layout.preferredWidth: parent.width * 0.15
                        Layout.fillHeight: true
                        onClicked: GlobalStates.quickSettingsOpen = !GlobalStates.quickSettingsOpen
                    }

                    // Carousel Area (Workspaces / Music / Weather)
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        StackLayout {
                            id: carouselStack
                            anchors.fill: parent
                            currentIndex: GlobalStates.carouselIndex

                            // 0: Workspaces
                            Item {
                                WorkspaceIndicator {
                                    id: wsIndicator
                                    anchors.centerIn: parent
                                    monitor: Hyprland.monitorFor(barWindow.screen)
                                }
                            }

                            // 1: Music (Small View)
                            RowLayout {
                                spacing: 8 * Appearance.effectiveScale
                                anchors.centerIn: parent
                                width: parent.width * 0.8

                                MaterialSymbol {
                                    text: "music_note"
                                    iconSize: 16 * Appearance.effectiveScale
                                    color: "white"
                                }
                                StyledText {
                                    text: MprisController.trackTitle
                                    font.pixelSize: 12 * Appearance.effectiveScale
                                    color: "white"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            // 2: Weather (Small View)
                            RowLayout {
                                spacing: 8 * Appearance.effectiveScale
                                anchors.centerIn: parent

                                MaterialSymbol {
                                    text: "cloud"
                                    iconSize: 16 * Appearance.effectiveScale
                                    color: "white"
                                }
                                StyledText {
                                    text: Weather.temp + "°C"
                                    font.pixelSize: 12 * Appearance.effectiveScale
                                    color: "white"
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.NoButton

                            onWheel: (wheel) => {
                                if (wheel.angleDelta.y > 0) {
                                    GlobalStates.carouselIndex = (GlobalStates.carouselIndex - 1 + 3) % 3;
                                } else {
                                    GlobalStates.cycleCarousel();
                                }
                            }
                        }
                    }

                    // Right Click Area -> Dashboard
                    MouseArea {
                        Layout.preferredWidth: parent.width * 0.15
                        Layout.fillHeight: true
                        onClicked: GlobalStates.dashboardOpen = !GlobalStates.dashboardOpen
                    }
                }            }
        }
    }
}

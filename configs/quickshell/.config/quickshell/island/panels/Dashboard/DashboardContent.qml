import "../../core"
import "../../core/functions" as Functions
import "../../widgets"
import "../../services"
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

/**
 * Dashboard panel with vertical Ambxst-style tab strip.
 */
Item {
    id: root
    signal closed()

    property bool active: GlobalStates.dashboardOpen
    property int currentTab: 0
    
    // Cava ref counting
    onCurrentTabChanged: {
        if (currentTab === 2) CavaService.refCount++;
        else CavaService.refCount--;
    }
    Component.onDestruction: {
        if (currentTab === 2) CavaService.refCount--;
    }

    // Equalizer State
    property var eqData: ({
        "b1": 0, "b2": 0, "b3": 0, "b4": 0, "b5": 0,
        "b6": 0, "b7": 0, "b8": 0, "b9": 0, "b10": 0,
        "preset": "Flat"
    })

    Process {
        id: eqGetProc
        command: ["bash", "-c", "$HOME/.config/hypr/scripts/quickshell/music/equalizer.sh get"]
        running: root.active && root.currentTab === 2
        stdout: StdioCollector {
            onStreamFinished: {
                try { if (this.text) root.eqData = JSON.parse(this.text); } catch(e) {}
            }
        }
    }

    function execEq(cmd) { Quickshell.execDetached(["bash", "-c", cmd]); }

    readonly property int tabCount: 5
    readonly property int tabButtonSize: 44 * Appearance.effectiveScale
    readonly property int tabStripWidth: tabButtonSize + 16 * Appearance.effectiveScale

    readonly property int panelWidth: 800 * Appearance.effectiveScale
    readonly property int panelHeight: 400 * Appearance.effectiveScale

    implicitWidth: panelWidth
    implicitHeight: panelHeight

    // ── Background ──
    Rectangle {
        id: panelBg
        anchors.fill: parent
        color: Appearance.m3colors.m3surfaceContainerLow
        radius: Appearance.rounding.large
        border.width: 1
        border.color: Functions.ColorUtils.applyAlpha(Appearance.m3colors.m3onSurface, 0.12)

        MouseArea {
            anchors.fill: parent
            onClicked: {} // Prevent click-through
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16 * Appearance.effectiveScale
            spacing: 16 * Appearance.effectiveScale

            Item {
                id: tabStrip
                Layout.fillHeight: true
                width: root.tabStripWidth

                // Background container
                Rectangle {
                    anchors.centerIn: parent
                    width: root.tabButtonSize + 12 * Appearance.effectiveScale
                    height: (root.tabButtonSize + 8 * Appearance.effectiveScale) * root.tabCount
                    radius: Appearance.rounding.medium
                    color: Appearance.colors.colLayer2
                    opacity: 0.5
                }

                // Active Tab Indicator (Warp)
                Rectangle {
                    id: tabWarp
                    width: root.tabButtonSize
                    height: root.tabButtonSize
                    radius: 12 * Appearance.effectiveScale
                    color: Appearance.colors.colPrimaryContainer
                    x: (parent.width - width) / 2
                    y: (parent.height - (root.tabButtonSize + 8 * Appearance.effectiveScale) * root.tabCount) / 2 + root.currentTab * (root.tabButtonSize + 8 * Appearance.effectiveScale)
                    Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                }

                // Icons
                Column {
                    anchors.centerIn: parent
                    spacing: 8 * Appearance.effectiveScale

                    Repeater {
                        model: [
                            { icon: "analytics", tooltip: "Performance" },
                            { icon: "cloud", tooltip: "Weather" },
                            { icon: "music_note", tooltip: "Music" },
                            { icon: "event", tooltip: "Schedule" },
                            { icon: "hub", tooltip: "GitHub" }
                        ]
                        delegate: Item {
                            width: root.tabButtonSize
                            height: root.tabButtonSize
                            z: 1

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: modelData.icon
                                iconSize: 24 * Appearance.effectiveScale
                                color: root.currentTab === index ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.currentTab = index
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
            }

            // ── Content Area ──
            StackLayout {
                id: contentStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: root.currentTab
                
                // NAnDoroid-style transition
                Behavior on currentIndex {
                    SequentialAnimation {
                        NumberAnimation { target: contentStack; property: "opacity"; to: 0; duration: 150; easing.type: Easing.OutQuart }
                        PropertyAction { target: contentStack; property: "currentIndex" }
                        NumberAnimation { target: contentStack; property: "opacity"; to: 1; duration: 150; easing.type: Easing.OutQuart }
                    }
                }

                // Tab 0: Performance
                ColumnLayout {
                    spacing: 12 * Appearance.effectiveScale
                    StyledText { text: "System Performance"; font.pixelSize: 20 * Appearance.effectiveScale; font.weight: Font.Bold }
                    
                    GridLayout {
                        columns: 2
                        StyledText { text: "CPU Usage:" }
                        StyledProgressBar { value: SystemData.cpuUsage; Layout.fillWidth: true }
                        
                        StyledText { text: "Memory:" }
                        StyledProgressBar { value: SystemData.memUsage; Layout.fillWidth: true }
                        
                        StyledText { text: "Uptime:" }
                        StyledText { text: SystemData.uptime }
                    }

                    // Power Profiles
                    RowLayout {
                        spacing: 8 * Appearance.effectiveScale
                        Repeater {
                            model: ["daily", "balanced", "performance"]
                            delegate: Rectangle {
                                width: 80 * Appearance.effectiveScale
                                height: 32 * Appearance.effectiveScale
                                radius: 8 * Appearance.effectiveScale
                                color: PowerProfileService.currentProfile === modelData ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer2
                                StyledText { anchors.centerIn: parent; text: modelData; font.pixelSize: 12 * Appearance.effectiveScale }
                                MouseArea { anchors.fill: parent; onClicked: PowerProfileService.setProfile(modelData) }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }

                // Tab 1: Weather
                WeatherCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // Tab 2: Music
                RowLayout {
                    spacing: 32 * Appearance.effectiveScale
                    
                    // Left Side: Player
                    ColumnLayout {
                        Layout.preferredWidth: 350 * Appearance.effectiveScale
                        spacing: 16 * Appearance.effectiveScale
                        
                        RowLayout {
                            spacing: 16 * Appearance.effectiveScale
                            
                            // Rotating Record
                            Rectangle {
                                width: 120 * Appearance.effectiveScale
                                height: 120 * Appearance.effectiveScale
                                radius: width / 2
                                color: "black"
                                border.width: 3 * Appearance.effectiveScale
                                border.color: MprisController.dynPrimary
                                clip: true
                                
                                Image {
                                    anchors.fill: parent
                                    source: MprisController.displayedArtFilePath || ""
                                    fillMode: Image.PreserveAspectCrop
                                    
                                    RotationAnimation on rotation {
                                        from: 0; to: 360; duration: 5000; loops: Animation.Infinite; running: MprisController.isPlaying
                                    }
                                }
                                
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 15 * Appearance.effectiveScale
                                    height: 15 * Appearance.effectiveScale
                                    radius: width / 2
                                    color: Appearance.m3colors.m3surfaceContainerLow
                                }
                            }
                            
                            ColumnLayout {
                                spacing: 4 * Appearance.effectiveScale
                                StyledText {
                                    text: MprisController.trackTitle
                                    font.pixelSize: 18 * Appearance.effectiveScale
                                    font.weight: Font.Bold
                                    color: Appearance.colors.colOnLayer0
                                    Layout.maximumWidth: 200 * Appearance.effectiveScale
                                    elide: Text.ElideRight
                                }
                                StyledText {
                                    text: MprisController.trackArtist
                                    font.pixelSize: 14 * Appearance.effectiveScale
                                    color: MprisController.dynSubtext
                                }
                                
                                RowLayout {
                                    spacing: 12 * Appearance.effectiveScale
                                    RippleButton {
                                        implicitWidth: 36 * Appearance.effectiveScale; implicitHeight: 36 * Appearance.effectiveScale
                                        buttonRadius: 18 * Appearance.effectiveScale
                                        onClicked: MprisController.previous()
                                        MaterialSymbol { anchors.centerIn: parent; text: "skip_previous"; iconSize: 24 * Appearance.effectiveScale }
                                    }
                                    RippleButton {
                                        implicitWidth: 44 * Appearance.effectiveScale; implicitHeight: 44 * Appearance.effectiveScale
                                        buttonRadius: 22 * Appearance.effectiveScale
                                        colBackground: MprisController.dynPrimary
                                        onClicked: MprisController.togglePlaying()
                                        MaterialSymbol { 
                                            anchors.centerIn: parent; text: MprisController.isPlaying ? "pause" : "play_arrow"; 
                                            iconSize: 28 * Appearance.effectiveScale; color: MprisController.dynOnPrimary
                                        }
                                    }
                                    RippleButton {
                                        implicitWidth: 36 * Appearance.effectiveScale; implicitHeight: 36 * Appearance.effectiveScale
                                        buttonRadius: 18 * Appearance.effectiveScale
                                        onClicked: MprisController.next()
                                        MaterialSymbol { anchors.centerIn: parent; text: "skip_next"; iconSize: 24 * Appearance.effectiveScale }
                                    }
                                }
                            }
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2 * Appearance.effectiveScale
                            StyledSlider {
                                Layout.fillWidth: true
                                value: MprisController.position
                                to: MprisController.length
                                enabled: false
                            }
                            RowLayout {
                                StyledText { text: Functions.StringUtils.friendlyTimeForSeconds(MprisController.position); font.pixelSize: 10 * Appearance.effectiveScale }
                                Item { Layout.fillWidth: true }
                                StyledText { text: Functions.StringUtils.friendlyTimeForSeconds(MprisController.length); font.pixelSize: 10 * Appearance.effectiveScale }
                            }
                        }

                        MusicWidget {
                            Layout.fillWidth: true
                        }
                    }

                    // Right Side: Equalizer
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 12 * Appearance.effectiveScale
                        
                        RowLayout {
                            StyledText { text: "Equalizer: " + root.eqData.preset; font.pixelSize: 16 * Appearance.effectiveScale; font.weight: Font.Bold; Layout.fillWidth: true }
                            RippleButton {
                                implicitWidth: 80 * Appearance.effectiveScale; implicitHeight: 28 * Appearance.effectiveScale
                                buttonRadius: 14 * Appearance.effectiveScale
                                onClicked: execEq("$HOME/.config/hypr/scripts/quickshell/music/equalizer.sh apply")
                                StyledText { anchors.centerIn: parent; text: "Apply"; font.pixelSize: 12 * Appearance.effectiveScale }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 150 * Appearance.effectiveScale
                            spacing: 8 * Appearance.effectiveScale
                            
                            Repeater {
                                model: 10
                                delegate: ColumnLayout {
                                    spacing: 4 * Appearance.effectiveScale
                                    Slider {
                                        orientation: Qt.Vertical
                                        from: -12; to: 12; stepSize: 1
                                        value: root.eqData["b" + (index + 1)] || 0
                                        Layout.fillHeight: true
                                        onMoved: execEq(`$HOME/.config/hypr/scripts/quickshell/music/equalizer.sh set_band ${index + 1} ${Math.round(value)}`)
                                    }
                                    StyledText { 
                                        text: ["31", "63", "125", "250", "500", "1k", "2k", "4k", "8k", "16k"][index]
                                        font.pixelSize: 8 * Appearance.effectiveScale
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                        }

                        RowLayout {
                            spacing: 8 * Appearance.effectiveScale
                            Repeater {
                                model: ["Flat", "Bass", "Treble", "Rock", "Pop"]
                                delegate: Rectangle {
                                    width: 50 * Appearance.effectiveScale; height: 24 * Appearance.effectiveScale
                                    radius: 6 * Appearance.effectiveScale
                                    color: root.eqData.preset === modelData ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer2
                                    StyledText { anchors.centerIn: parent; text: modelData; font.pixelSize: 10 * Appearance.effectiveScale }
                                    MouseArea { anchors.fill: parent; onClicked: execEq(`$HOME/.config/hypr/scripts/quickshell/music/equalizer.sh preset ${modelData}`) }
                                }
                            }
                        }
                    }
                }

                // Tab 3: Schedule
                DashSchedule {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                // Tab 4: GitHub
                DashGitHub {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
}

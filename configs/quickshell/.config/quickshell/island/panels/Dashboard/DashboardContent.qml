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
    property int panelHeight: currentTab === 2 ? 650 * Appearance.effectiveScale : 450 * Appearance.effectiveScale
    Behavior on panelHeight { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }

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
                    spacing: 16 * Appearance.effectiveScale
                    
                    RowLayout {
                        spacing: 16 * Appearance.effectiveScale
                        ColumnLayout {
                            Layout.fillWidth: true
                            StyledText { text: "CPU Usage"; font.pixelSize: 14 * Appearance.effectiveScale; color: Appearance.colors.colSubtext }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 100 * Appearance.effectiveScale
                                PerformanceGraph {
                                    anchors.fill: parent
                                    history: SystemData.cpuHistory
                                    color: Appearance.colors.colPrimary
                                }
                                StyledText {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 4 * Appearance.effectiveScale
                                    text: Math.round(SystemData.cpuUsage * 100) + "%"
                                    font.pixelSize: 12 * Appearance.effectiveScale
                                    font.weight: Font.Bold
                                    color: Appearance.colors.colPrimary
                                }
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            StyledText { text: "RAM Usage"; font.pixelSize: 14 * Appearance.effectiveScale; color: Appearance.colors.colSubtext }
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 100 * Appearance.effectiveScale
                                PerformanceGraph {
                                    anchors.fill: parent
                                    history: SystemData.memHistory
                                    color: Appearance.colors.colTertiary
                                }
                                StyledText {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 4 * Appearance.effectiveScale
                                    text: Math.round(SystemData.memUsage * 100) + "%"
                                    font.pixelSize: 12 * Appearance.effectiveScale
                                    font.weight: Font.Bold
                                    color: Appearance.colors.colTertiary
                                }
                            }
                        }
                    }

                    GridLayout {
                        columns: 3
                        rowSpacing: 16 * Appearance.effectiveScale
                        columnSpacing: 32 * Appearance.effectiveScale
                        Layout.fillWidth: true

                        // CPU Stats
                        ColumnLayout {
                            spacing: 2 * Appearance.effectiveScale
                            StyledText { text: "CPU"; font.weight: Font.Bold; font.pixelSize: 12 * Appearance.effectiveScale; color: Appearance.colors.colPrimary }
                            StyledText { text: (SystemData.cpuUsage * 100).toFixed(1) + "% (" + Math.round(SystemData.cpuTemperature) + "°C)" }
                            StyledText { text: SystemData.cpuModel; font.pixelSize: 10 * Appearance.effectiveScale; color: Appearance.colors.colSubtext; elide: Text.ElideRight; Layout.maximumWidth: 150 * Appearance.effectiveScale }
                        }

                        // GPU Stats
                        ColumnLayout {
                            spacing: 2 * Appearance.effectiveScale
                            StyledText { text: "GPU"; font.weight: Font.Bold; font.pixelSize: 12 * Appearance.effectiveScale; color: Appearance.colors.colSecondary }
                            StyledText { 
                                text: SystemData.hasValidGpuData && SystemData.availableGpus.length > 0 ? 
                                    Math.round(SystemData.availableGpus[0].temp) + "°C" : "No Temp" 
                            }
                            StyledText { 
                                text: SystemData.availableGpus.length > 0 ? SystemData.availableGpus[0].name : "N/A"
                                font.pixelSize: 10 * Appearance.effectiveScale; color: Appearance.colors.colSubtext; elide: Text.ElideRight; Layout.maximumWidth: 150 * Appearance.effectiveScale 
                            }
                        }

                        // RAM Stats
                        ColumnLayout {
                            spacing: 2 * Appearance.effectiveScale
                            StyledText { text: "RAM"; font.weight: Font.Bold; font.pixelSize: 12 * Appearance.effectiveScale; color: Appearance.colors.colTertiary }
                            StyledText { text: (SystemData.usedMemoryMB / 1024).toFixed(1) + " / " + (SystemData.totalMemoryMB / 1024).toFixed(1) + " GB" }
                            StyledText { text: (SystemData.memUsage * 100).toFixed(1) + "% utilized"; font.pixelSize: 10 * Appearance.effectiveScale; color: Appearance.colors.colSubtext }
                        }

                        // Disk Stats
                        ColumnLayout {
                            spacing: 2 * Appearance.effectiveScale
                            StyledText { text: "DISK"; font.weight: Font.Bold; font.pixelSize: 12 * Appearance.effectiveScale; color: Appearance.colors.colSuccess }
                            StyledText { text: SystemData.diskStats.length > 0 ? (SystemData.diskStats[0].usage * 100).toFixed(1) + "% used" : "N/A" }
                            StyledText { text: SystemData.diskStats.length > 0 ? SystemData.diskStats[0].label : "/"; font.pixelSize: 10 * Appearance.effectiveScale; color: Appearance.colors.colSubtext }
                        }

                        // Session Stats
                        ColumnLayout {
                            spacing: 2 * Appearance.effectiveScale
                            StyledText { text: "SESSION"; font.weight: Font.Bold; font.pixelSize: 12 * Appearance.effectiveScale; color: Appearance.colors.colWarning }
                            StyledText { text: SystemData.uptime + " uptime" }
                            StyledText { text: "Kernel: " + SystemInfo.kernel; font.pixelSize: 10 * Appearance.effectiveScale; color: Appearance.colors.colSubtext }
                        }
                        
                        // Updates Stats
                        ColumnLayout {
                            spacing: 4 * Appearance.effectiveScale
                            Layout.fillWidth: true
                            
                            RowLayout {
                                spacing: 8 * Appearance.effectiveScale
                                MaterialSymbol { text: "package"; iconSize: 18 * Appearance.effectiveScale; color: Appearance.colors.colError }
                                StyledText { text: "UPDATES"; font.weight: Font.Bold; font.pixelSize: 12 * Appearance.effectiveScale; color: Appearance.colors.colError }
                            }

                            RowLayout {
                                spacing: 12 * Appearance.effectiveScale
                                Layout.fillWidth: true

                                ColumnLayout {
                                    spacing: 0
                                    StyledText { text: SessionService.upgradeCount + " Pending"; font.pixelSize: 13 * Appearance.effectiveScale; font.weight: Font.Bold }
                                    StyledText { text: SessionService.packageCount + " installed"; font.pixelSize: 10 * Appearance.effectiveScale; color: Appearance.colors.colSubtext }
                                }

                                Item { Layout.fillWidth: true }

                                RippleButton {
                                    visible: SessionService.upgradeCount > 0
                                    implicitWidth: 80 * Appearance.effectiveScale
                                    implicitHeight: 32 * Appearance.effectiveScale
                                    buttonRadius: 8 * Appearance.effectiveScale
                                    colBackground: Appearance.colors.colError
                                    colRipple: Appearance.colors.colOnError
                                    onClicked: SessionService.update()
                                    
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 4 * Appearance.effectiveScale
                                        MaterialSymbol { text: "upgrade"; iconSize: 16 * Appearance.effectiveScale; color: "white" }
                                        StyledText { text: "Update"; font.pixelSize: 11 * Appearance.effectiveScale; font.weight: Font.Bold; color: "white" }
                                    }
                                }
                            }
                        }
                    }

                    // Power Profiles
                    ColumnLayout {
                        spacing: 8 * Appearance.effectiveScale
                        StyledText { text: "Power Management"; font.pixelSize: 14 * Appearance.effectiveScale; font.weight: Font.Bold }
                        RowLayout {
                            spacing: 12 * Appearance.effectiveScale
                            Repeater {
                                model: ["daily", "balanced", "performance"]
                                delegate: Rectangle {
                                    width: 120 * Appearance.effectiveScale
                                    height: 40 * Appearance.effectiveScale
                                    radius: 10 * Appearance.effectiveScale
                                    color: PowerProfileService.currentProfile === modelData ? Appearance.colors.colPrimaryContainer : Appearance.colors.colLayer2
                                    border.width: 1
                                    border.color: PowerProfileService.currentProfile === modelData ? Appearance.colors.colPrimary : "transparent"
                                    
                                    RowLayout {
                                        anchors.centerIn: parent
                                        spacing: 8 * Appearance.effectiveScale
                                        MaterialSymbol {
                                            text: modelData === "daily" ? "eco" : (modelData === "balanced" ? "balance" : "bolt")
                                            iconSize: 18 * Appearance.effectiveScale
                                            color: PowerProfileService.currentProfile === modelData ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colSubtext
                                        }
                                        StyledText { 
                                            text: modelData === "daily" ? "Power Saver" : (modelData === "balanced" ? "Balanced" : "Performance")
                                            font.pixelSize: 12 * Appearance.effectiveScale
                                            font.weight: PowerProfileService.currentProfile === modelData ? Font.Bold : Font.Normal
                                            color: PowerProfileService.currentProfile === modelData ? Appearance.colors.colOnPrimaryContainer : Appearance.colors.colOnLayer0
                                        }
                                    }
                                    MouseArea { 
                                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor;
                                        onClicked: PowerProfileService.setProfile(modelData) 
                                    }
                                }
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
                MusicPopup {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
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

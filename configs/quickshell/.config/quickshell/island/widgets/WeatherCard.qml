import "../core"
import "../services"
import "."
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell

import "./weather"

/**
 * Advanced Weather widget with Nandroid aesthetics and browsing features.
 */
Rectangle {
    id: root
    implicitHeight: mainLayout.implicitHeight
    radius: Appearance.rounding.card
    color: Appearance.m3colors.m3surfaceContainerLow
    
    // State for browsing
    property int selectedDayIndex: 0
    property int focusedHourIndex: -1 // -1 means "Current"
    property bool showDetails: false

    function parseLocalDate(s) {
        if (!s) return new Date();
        let p = s.split(/\D/);
        return new Date(p[0], p[1]-1, p[2]);
    }

    // Helpers to get data based on selection
    readonly property var currentDay: Weather.daily.length > selectedDayIndex ? Weather.daily[selectedDayIndex] : null
    readonly property list<var> currentDayHourly: {
        if (!currentDay || Weather.hourly.length === 0) return [];
        let dateStr = currentDay.fullDate;
        return Weather.hourly.filter(h => h.fullTime.startsWith(dateStr));
    }
    
    readonly property var displayData: {
        if (focusedHourIndex === -1 && selectedDayIndex === 0) return Weather.current;
        let hourly = currentDayHourly;
        if (focusedHourIndex >= 0 && focusedHourIndex < hourly.length) return hourly[focusedHourIndex];
        return Weather.current;
    }

    // Clipping mask
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle { width: root.width; height: root.height; radius: root.radius }
    }
    
    readonly property string weatherIconsDir: "assets/icons/google-weather"
    readonly property color contentColor: Appearance.m3colors.m3onSurface

    // --- Atmospheric Overlay ---
    WeatherAnimation {
        id: weatherAnim
        anchors.fill: parent
        animationsEnabled: root.visible
        backgroundEnabled: false 
    }

    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 16 * Appearance.effectiveScale
        anchors.margins: 20 * Appearance.effectiveScale

        // ── Header: Location & Date Selector ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            ColumnLayout {
                spacing: 2 * Appearance.effectiveScale
                StyledText {
                    text: Weather.location
                    font.pixelSize: 18 * Appearance.effectiveScale
                    font.weight: Font.Bold
                    color: root.contentColor
                }
                StyledText {
                    text: {
                        if (focusedHourIndex === -1 && selectedDayIndex === 0) return "Current Conditions";
                        if (!currentDay) return "Checking...";
                        let date = parseLocalDate(currentDay.fullDate);
                        let dateStr = date.getDate() + " " + date.toLocaleString('default', { month: 'short' });
                        return (focusedHourIndex === -1 ? "Forecast" : "Forecast for " + displayData.time) + " • " + dateStr;
                    }
                    font.pixelSize: 12 * Appearance.effectiveScale
                    color: root.contentColor
                    opacity: 0.7
                }
            }

            Item { Layout.fillWidth: true }

            // Date Selector: < {dd mm} >
            RowLayout {
                spacing: 8 * Appearance.effectiveScale
                
                MaterialSymbol {
                    text: "chevron_left"
                    iconSize: 20 * Appearance.effectiveScale
                    color: selectedDayIndex > 0 ? root.contentColor : Appearance.colors.colSubtext
                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (selectedDayIndex > 0) { selectedDayIndex--; focusedHourIndex = -1; }
                    }
                }

                Rectangle {
                    implicitWidth: 80 * Appearance.effectiveScale
                    implicitHeight: 28 * Appearance.effectiveScale
                    radius: 14 * Appearance.effectiveScale
                    color: Appearance.colors.colLayer2
                    StyledText {
                        anchors.centerIn: parent
                        text: {
                            if (!currentDay) return "--";
                            let d = parseLocalDate(currentDay.fullDate);
                            return d.getDate() + " " + d.toLocaleString('default', { month: 'short' });
                        }
                        font.pixelSize: 12 * Appearance.effectiveScale
                        font.weight: Font.Medium
                    }
                }

                MaterialSymbol {
                    text: "chevron_right"
                    iconSize: 20 * Appearance.effectiveScale
                    color: selectedDayIndex < 6 ? root.contentColor : Appearance.colors.colSubtext
                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (selectedDayIndex < 6) { selectedDayIndex++; focusedHourIndex = -1; }
                    }
                }
            }
        }

        // ── Primary Info (Large Display) ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 20 * Appearance.effectiveScale

            CustomIcon {
                source: displayData.icon || "cloudy"
                iconFolder: root.weatherIconsDir
                width: 80 * Appearance.effectiveScale; height: 80 * Appearance.effectiveScale; colorize: false
            }

            ColumnLayout {
                spacing: 0
                StyledText {
                    text: (displayData.temp || "--") + "°"
                    font.pixelSize: 54 * Appearance.effectiveScale
                    font.weight: Font.Light
                    color: root.contentColor
                }
                StyledText {
                    text: displayData.condition || "Checking..."
                    font.pixelSize: 16 * Appearance.effectiveScale
                    color: root.contentColor
                    opacity: 0.8
                }
            }

            Item { Layout.fillWidth: true }

            // Detail trigger
            Rectangle {
                width: 40 * Appearance.effectiveScale; height: 40 * Appearance.effectiveScale
                radius: 20 * Appearance.effectiveScale
                color: showDetails ? Appearance.colors.colPrimary : Appearance.colors.colLayer2
                MaterialSymbol {
                    anchors.centerIn: parent
                    text: showDetails ? "expand_less" : "expand_more"
                    color: showDetails ? "white" : root.contentColor
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: root.showDetails = !root.showDetails
                }
            }
        }

        // ── Details Segment (Animated) ──
        ColumnLayout {
            id: detailSegment
            visible: root.showDetails
            Layout.fillWidth: true
            spacing: 12 * Appearance.effectiveScale
            clip: true
            
            Rectangle {
                Layout.fillWidth: true
                height: 1 * Appearance.effectiveScale
                color: root.contentColor
                opacity: 0.1
            }

            GridLayout {
                columns: 3
                Layout.fillWidth: true
                rowSpacing: 10 * Appearance.effectiveScale

                // Detail Items
                ColumnLayout {
                    spacing: 2 * Appearance.effectiveScale
                    StyledText { text: "HUMIDITY"; font.pixelSize: 9 * Appearance.effectiveScale; font.weight: Font.Bold; opacity: 0.6 }
                    StyledText { text: (displayData.humidity || "--") + "%"; font.weight: Font.Medium }
                }
                ColumnLayout {
                    spacing: 2 * Appearance.effectiveScale
                    StyledText { text: "WIND"; font.pixelSize: 9 * Appearance.effectiveScale; font.weight: Font.Bold; opacity: 0.6 }
                    StyledText { text: (displayData.windSpeed || "--") + " km/h"; font.weight: Font.Medium }
                }
                ColumnLayout {
                    spacing: 2 * Appearance.effectiveScale
                    StyledText { text: "CLOUDS"; font.pixelSize: 9 * Appearance.effectiveScale; font.weight: Font.Bold; opacity: 0.6 }
                    StyledText { text: (displayData.cloudCover !== undefined ? displayData.cloudCover : "--") + "%"; font.weight: Font.Medium }
                }
                ColumnLayout {
                    spacing: 2 * Appearance.effectiveScale
                    StyledText { text: "RAIN"; font.pixelSize: 9 * Appearance.effectiveScale; font.weight: Font.Bold; opacity: 0.6 }
                    StyledText { text: (displayData.precipProb !== undefined ? displayData.precipProb : (currentDay?.precipSum || "0")) + "%"; font.weight: Font.Medium }
                }
                ColumnLayout {
                    spacing: 2 * Appearance.effectiveScale
                    StyledText { text: "FEELS LIKE"; font.pixelSize: 9 * Appearance.effectiveScale; font.weight: Font.Bold; opacity: 0.6 }
                    StyledText { text: (displayData.feelsLike || "--") + "°"; font.weight: Font.Medium }
                }
                ColumnLayout {
                    spacing: 2 * Appearance.effectiveScale
                    StyledText { text: "RANGE"; font.pixelSize: 9 * Appearance.effectiveScale; font.weight: Font.Bold; opacity: 0.6 }
                    StyledText { text: (currentDay?.maxTemp || "--") + "° / " + (currentDay?.minTemp || "--") + "°"; font.weight: Font.Medium }
                }
            }
        }

        // ── Hourly Browser (Scroll Area) ──
        Item {
            Layout.fillWidth: true
            implicitHeight: 80 * Appearance.effectiveScale
            
            RowLayout {
                anchors.fill: parent
                spacing: 0
                Repeater {
                    model: root.currentDayHourly
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: index === focusedHourIndex ? Appearance.colors.colPrimaryContainer : "transparent"
                        radius: 8 * Appearance.effectiveScale
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4 * Appearance.effectiveScale
                            StyledText {
                                text: modelData.time; font.pixelSize: 9 * Appearance.effectiveScale
                                opacity: index === focusedHourIndex ? 1.0 : 0.6
                                Layout.alignment: Qt.AlignHCenter
                            }
                            CustomIcon {
                                source: modelData.icon
                                iconFolder: root.weatherIconsDir
                                width: 24 * Appearance.effectiveScale; height: 24 * Appearance.effectiveScale; colorize: false
                                Layout.alignment: Qt.AlignHCenter
                            }
                            StyledText {
                                text: modelData.temp + "°"; font.pixelSize: 11 * Appearance.effectiveScale; font.weight: Font.Bold
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                focusedHourIndex = index;
                                root.showDetails = true;
                            }
                        }
                    }
                }
            }

            // Scroll Handling
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0) {
                        if (focusedHourIndex > -1) focusedHourIndex--;
                    } else {
                        if (focusedHourIndex < root.currentDayHourly.length - 1) focusedHourIndex++;
                    }
                }
            }
        }

        // ── Footer ──
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 20 * Appearance.effectiveScale
            
            StyledText {
                id: timestampText
                anchors.centerIn: parent
                font.pixelSize: 9 * Appearance.effectiveScale
                color: root.contentColor; opacity: 0.5; textFormat: Text.StyledText
                
                property string timeString: "just now"
                text: Weather.loading ? Weather.status : `Updated ${timeString} • Scroll to browse forecast`
                
                function updateRelativeTime() {
                    if (!Weather.lastUpdateTime) { timeString = "unknown"; return; }
                    let diff = Math.floor((new Date() - Weather.lastUpdateTime) / 60000);
                    if (diff < 1) timeString = "just now";
                    else if (diff < 60) timeString = diff + " mins ago";
                    else timeString = Math.floor(diff / 60) + " hours ago";
                }
                Timer { interval: 60000; running: true; repeat: true; onTriggered: timestampText.updateRelativeTime(); triggeredOnStart: true }
            }
            MouseArea { anchors.fill: parent; onClicked: Weather.fetch() }
        }
    }
}

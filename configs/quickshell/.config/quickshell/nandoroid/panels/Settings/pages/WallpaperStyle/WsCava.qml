import "../../../../core"
import "../../../../services"
import "../../../../widgets"
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 0

    SearchHandler { 
        searchString: "Visualizer"
        aliases: ["Cava", "Audio", "Desktop Cava", "Lockscreen Cava"]
    }

    // ── Visualizer Section ──
    ColumnLayout {
        Layout.fillWidth: true
        Layout.topMargin: 12 * Appearance.effectiveScale
        spacing: 16 * Appearance.effectiveScale

        // Section Header
        RowLayout {
            spacing: 12 * Appearance.effectiveScale
            Layout.bottomMargin: 4 * Appearance.effectiveScale

            MaterialSymbol {
                text: "equalizer"
                iconSize: 24 * Appearance.effectiveScale
                color: Appearance.colors.colPrimary
            }
            StyledText {
                text: "Audio Visualizer"
                font.pixelSize: Appearance.font.pixelSize.large
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer1
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4 * Appearance.effectiveScale

            // --- Desktop Visualizer Toggle ---
            SegmentedWrapper {
                Layout.fillWidth: true
                implicitHeight: desktopCavaRow.implicitHeight + (32 * Appearance.effectiveScale)
                orientation: Qt.Vertical
                maxRadius: 20 * Appearance.effectiveScale
                color: Appearance.m3colors.m3surfaceContainerHigh
                RowLayout {
                    id: desktopCavaRow
                    anchors.fill: parent; anchors.margins: 16 * Appearance.effectiveScale
                    spacing: 16 * Appearance.effectiveScale
                    MaterialSymbol { text: "desktop_windows"; iconSize: 24 * Appearance.effectiveScale; color: Appearance.colors.colPrimary }
                    StyledText { text: "Show on desktop"; Layout.fillWidth: true; color: Appearance.colors.colOnLayer1 }
                    AndroidToggle {
                        checked: Config.ready && Config.options.appearance.background.showCava
                        onToggled: if(Config.ready) Config.options.appearance.background.showCava = !checked
                    }
                }
            }

            // --- Desktop Opacity Slider ---
            SegmentedWrapper {
                Layout.fillWidth: true
                visible: Config.ready && Config.options.appearance.background.showCava
                implicitHeight: desktopOpacityRow.implicitHeight + (32 * Appearance.effectiveScale)
                orientation: Qt.Vertical
                maxRadius: 20 * Appearance.effectiveScale
                color: Appearance.m3colors.m3surfaceContainerHigh
                RowLayout {
                    id: desktopOpacityRow
                    anchors.fill: parent; anchors.margins: 16 * Appearance.effectiveScale
                    spacing: 20 * Appearance.effectiveScale
                    RowLayout {
                        spacing: 16 * Appearance.effectiveScale
                        Layout.preferredWidth: 70 * Appearance.effectiveScale
                        MaterialSymbol { text: "opacity"; iconSize: 24 * Appearance.effectiveScale; color: Appearance.colors.colPrimary }
                        StyledText { text: "Desktop opacity"; Layout.fillWidth: true; color: Appearance.colors.colOnLayer1 }
                    }
                    StyledSlider {
                        Layout.fillWidth: true
                        from: 0.05; to: 0.5
                        value: Config.options.appearance.background.cavaOpacity
                        onMoved: Config.options.appearance.background.cavaOpacity = value
                    }
                    StyledText {
                        text: Math.round(Config.options.appearance.background.cavaOpacity * 100) + "%"
                        color: Appearance.colors.colOnLayer1
                        Layout.preferredWidth: 40 * Appearance.effectiveScale
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }

            // --- Lockscreen Visualizer Toggle ---
            SegmentedWrapper {
                Layout.fillWidth: true
                implicitHeight: lockCavaRow.implicitHeight + (32 * Appearance.effectiveScale)
                orientation: Qt.Vertical
                maxRadius: 20 * Appearance.effectiveScale
                color: Appearance.m3colors.m3surfaceContainerHigh
                RowLayout {
                    id: lockCavaRow
                    anchors.fill: parent; anchors.margins: 16 * Appearance.effectiveScale
                    spacing: 16 * Appearance.effectiveScale
                    MaterialSymbol { text: "lock"; iconSize: 24 * Appearance.effectiveScale; color: Appearance.colors.colPrimary }
                    StyledText { text: "Show on lock screen"; Layout.fillWidth: true; color: Appearance.colors.colOnLayer1 }
                    AndroidToggle {
                        checked: Config.ready && Config.options.lock.showCava
                        onToggled: if(Config.ready) Config.options.lock.showCava = !checked
                    }
                }
            }

            // --- Lockscreen Opacity Slider ---
            SegmentedWrapper {
                Layout.fillWidth: true
                visible: Config.ready && Config.options.lock.showCava
                implicitHeight: lockOpacityRow.implicitHeight + (32 * Appearance.effectiveScale)
                orientation: Qt.Vertical
                maxRadius: 20 * Appearance.effectiveScale
                color: Appearance.m3colors.m3surfaceContainerHigh
                RowLayout {
                    id: lockOpacityRow
                    anchors.fill: parent; anchors.margins: 16 * Appearance.effectiveScale
                    spacing: 20 * Appearance.effectiveScale
                    RowLayout {
                        spacing: 16 * Appearance.effectiveScale
                        Layout.preferredWidth: 70 * Appearance.effectiveScale
                        MaterialSymbol { text: "opacity"; iconSize: 24 * Appearance.effectiveScale; color: Appearance.colors.colPrimary }
                        StyledText { text: "Lock screen opacity"; Layout.fillWidth: true; color: Appearance.colors.colOnLayer1 }
                    }
                    StyledSlider {
                        Layout.fillWidth: true
                        from: 0.05; to: 0.5
                        value: Config.options.lock.cavaOpacity
                        onMoved: Config.options.lock.cavaOpacity = value
                    }
                    StyledText {
                        text: Math.round(Config.options.lock.cavaOpacity * 100) + "%"
                        color: Appearance.colors.colOnLayer1
                        Layout.preferredWidth: 40 * Appearance.effectiveScale
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import "../services"
import "../core"

/**
 * Cava visualizer widget.
 * Uses CavaService for audio data.
 */
Row {
    id: root
    spacing: 2 * Appearance.effectiveScale
    property color barColor: Appearance.m3colors.m3primary
    property int barWidth: Math.max(1, (width - (spacing * (barCount - 1))) / barCount)
    property int maxHeight: 40 * Appearance.effectiveScale
    property int barCount: CavaService.barCount
    height: maxHeight

    // Manage ref count for the service
    Component.onCompleted: CavaService.refCount++
    Component.onDestruction: CavaService.refCount--

    Repeater {
        model: root.barCount
        delegate: Rectangle {
            width: root.barWidth
            height: Math.min(root.maxHeight, Math.max(2 * Appearance.effectiveScale, (CavaService.values[index] / 1000) * root.maxHeight))
            radius: 2 * Appearance.effectiveScale // Small radius for a modern but classic look
            color: root.barColor
            anchors.bottom: parent.bottom

            Behavior on height {
                NumberAnimation { duration: 60; easing.type: Easing.OutQuint }
            }
        }
    }
}

// modules/BarTooltip.qml
// Reparents to window root so it renders outside the island's bounds.
// Pass `sourceItem: <the hovered item>` so x aligns correctly.
import QtQuick

Rectangle {
    id: tip

    required property string text
    required property bool show
    // The item to align the tooltip under (pass the module's root Item)
    property var sourceItem: parent

    visible: show && text !== ""
    z: 999

    color: "#1e1e24"
    border.color: Qt.rgba(1,1,1,0.12)
    border.width: 1
    radius: 5
    width: label.implicitWidth + 12
    height: label.implicitHeight + 8

    property var _origParent: null
    property var _rootItem: null

    Component.onCompleted: {
        _origParent = tip.parent
        // Walk to the top-level window content item
        var p = tip.parent
        while (p.parent && p.parent.parent) p = p.parent
        _rootItem = p
        tip.parent = p
        updatePos()
    }

    function updatePos() {
        if (!_rootItem || !sourceItem) return
        var mapped = sourceItem.mapToItem(_rootItem, 0, 0)
        tip.x = Math.max(4, Math.min(
            _rootItem.width - tip.width - 4,
            mapped.x + sourceItem.width / 2 - tip.width / 2
        ))
        // Island bottom is at topMargin(7) + height(28) + gap(4) = 39
        tip.y = 39
    }

    onVisibleChanged: if (visible) updatePos()
    onSourceItemChanged: updatePos()

    Text {
        id: label
        anchors.centerIn: parent
        text: tip.text
        font.pixelSize: 11
        color: "#dddddd"
    }
}

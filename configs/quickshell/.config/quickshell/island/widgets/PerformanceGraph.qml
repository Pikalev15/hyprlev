import QtQuick
import QtQuick.Effects
import "../core"
import "../services"

Canvas {
    id: root
    
    property var history: []
    property color color: Appearance.colors.colPrimary
    property real maxVal: 100
    property bool fill: true

    onHistoryChanged: root.requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        if (!history || history.length < 2) return;

        var h = height;
        var w = width;
        var n = history.length;

        ctx.beginPath();
        // Start from bottom left
        ctx.moveTo(0, h);

        for (var i = 0; i < n; i++) {
            var x = (i * w) / (n - 1);
            var y = h - (history[i] / maxVal) * h;
            // Clamp y to 0..h
            y = Math.max(0, Math.min(h, y));
            ctx.lineTo(x, y);
        }

        if (fill) {
            // Close the path to the bottom right and back to start
            ctx.lineTo(w, h);
            ctx.lineTo(0, h);
            ctx.closePath();

            ctx.fillStyle = Qt.rgba(color.r, color.g, color.b, 0.2);
            ctx.fill();
        }

        // Draw the line on top
        ctx.beginPath();
        for (var i = 0; i < n; i++) {
            var x = (i * w) / (n - 1);
            var y = h - (history[i] / maxVal) * h;
            y = Math.max(0, Math.min(h, y));
            if (i === 0) ctx.moveTo(x, y);
            else ctx.lineTo(x, y);
        }

        ctx.strokeStyle = color;
        ctx.lineWidth = 2 * Appearance.effectiveScale;
        ctx.stroke();
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        source: root
        blurEnabled: true
        blurMax: 4
        blur: 0.2
    }
}

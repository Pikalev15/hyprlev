// modules/SystemTray.qml — Resource stats + status icons
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

RowLayout {
    id: root
    spacing: 10

    // ── CPU + RAM combined indicator (the "71" in screenshot) ────
    ResourceIndicator {}

    // ── Network (WiFi) ───────────────────────────────────────────
    NetworkIcon {}

    // ── Bluetooth ────────────────────────────────────────────────
    TrayIcon {
        iconName: "bluetooth-symbolic"
        tooltip: "Bluetooth"
    }

    // ── Audio / Volume ───────────────────────────────────────────
    AudioIcon {}

    // ── Battery ──────────────────────────────────────────────────
    BatteryIcon {}
}

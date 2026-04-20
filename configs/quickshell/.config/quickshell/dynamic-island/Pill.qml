import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import "./core"
import "./core/functions" as Functions
import "./services"
import "./widgets"

/**
 * Dynamic Island replicated from Nandoroid statusbar.
 */
Rectangle {
    id: root
    
    // Default Nandoroid-like sizing
    implicitWidth: 180 * Appearance.effectiveScale
    implicitHeight: 28 * Appearance.effectiveScale
    
    color: "black"
    radius: height / 2
    
    // State
    property bool expanded: false
    
    // Add interactions
    MouseArea {
        anchors.fill: parent
        onClicked: expanded = !expanded
    }

    // --- Content Loader ---
    Loader {
        anchors.fill: parent
        sourceComponent: expanded ? expandedView : collapsedView
    }

    Component {
        id: collapsedView
        RowLayout {
            anchors.centerIn: parent
            spacing: 6 * Appearance.effectiveScale
            // Replicate workspace indicator or other status bar items as needed
            // Example: Workspace Indicator Dots
            Repeater {
                model: 8
                Rectangle {
                    width: (Hyprland.activeWorkspace?.id === (index + 1)) ? 16 * Appearance.effectiveScale : 6 * Appearance.effectiveScale
                    height: 6 * Appearance.effectiveScale
                    radius: 3 * Appearance.effectiveScale
                    color: (Hyprland.activeWorkspace?.id === (index + 1)) ? "#EEE" : "#444"
                }
            }
        }
    }

    Component {
        id: expandedView
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15 * Appearance.effectiveScale
            spacing: 12 * Appearance.effectiveScale
            
            Text { text: "System Control"; color: "#666"; font.pixelSize: 10 * Appearance.effectiveScale; Layout.alignment: Qt.AlignHCenter }
            
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10 * Appearance.effectiveScale
                
                // Toggle Buttons Example
                Repeater {
                    model: [
                        { name: "WiFi", active: Network.connected },
                        { name: "BT", active: BluetoothStatus.connected },
                        { name: "Audio", active: true }
                    ]
                    Rectangle {
                        width: 80 * Appearance.effectiveScale; height: 60 * Appearance.effectiveScale; radius: 8 * Appearance.effectiveScale
                        color: modelData.active ? "#333" : "#201F20"

                        Column {
                            anchors.centerIn: parent
                            spacing: 4 * Appearance.effectiveScale
                            Text {
                                text: modelData.name === "WiFi" ? (modelData.active ? "wifi" : "wifi_off") 
                                    : modelData.name === "BT" ? (modelData.active ? "bluetooth" : "bluetooth_disabled") 
                                    : "volume_up"
                                font.pixelSize: 18 * Appearance.effectiveScale
                                color: "#E6E1E1"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text { 
                                text: modelData.name; color: "#E6E1E1"; 
                                font.pixelSize: 11 * Appearance.effectiveScale
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (modelData.name === "WiFi") Network.toggle()
                                else if (modelData.name === "BT") BluetoothStatus.toggle()
                                else Audio.toggleMute()
                            }
                        }
                    }                }
            }
        }
    }
}

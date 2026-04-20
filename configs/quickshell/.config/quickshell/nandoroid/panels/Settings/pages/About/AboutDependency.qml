import "../../../../core"
import "../../../../services"
import "../../../../widgets"
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Widgets
import Quickshell.Io

ColumnLayout {
    id: dependencyRoot
    spacing: 24 * Appearance.effectiveScale

    readonly property bool isScanning: SysCheckService.isChecking

    function scanDependencies() {
        SysCheckService.check();
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 80 * Appearance.effectiveScale
        radius: 20 * Appearance.effectiveScale
        color: Appearance.m3colors.m3surfaceContainerHigh
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20 * Appearance.effectiveScale
            anchors.rightMargin: 16 * Appearance.effectiveScale
            spacing: 16 * Appearance.effectiveScale
            
            MaterialSymbol {
                text: "account_tree"
                iconSize: 24 * Appearance.effectiveScale
                color: Appearance.colors.colPrimary
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2 * Appearance.effectiveScale
                StyledText {
                    text: "Dependency Scanner"
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnLayer1
                }
                StyledText {
                    text: SysCheckService.missingCount > 0 
                        ? `${SysCheckService.missingCount} critical components are missing.` 
                        : "All critical components are installed and ready."
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: SysCheckService.missingCount > 0 ? Appearance.colors.colError : Appearance.colors.colSubtext
                }
            }

            Item { Layout.fillWidth: true }

            RippleButton {
                implicitWidth: 140 * Appearance.effectiveScale
                implicitHeight: 40 * Appearance.effectiveScale
                buttonRadius: 20 * Appearance.effectiveScale
                colBackground: Appearance.colors.colPrimary
                onClicked: {
                    dependencyRoot.scanDependencies();
                }
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8 * Appearance.effectiveScale
                    MaterialSymbol {
                        text: "sync"
                        iconSize: 18 * Appearance.effectiveScale
                        color: Appearance.colors.colOnPrimary
                        // Add rotation animation if scanning
                        RotationAnimation on rotation {
                            running: SysCheckService.isChecking
                            from: 0; to: 360
                            duration: 1000
                            loops: Animation.Infinite
                        }
                    }
                    StyledText {
                        text: SysCheckService.isChecking ? "Scanning..." : "Scan Now"
                        color: Appearance.colors.colOnPrimary
                        font.weight: Font.Medium
                        font.pixelSize: Appearance.font.pixelSize.small
                    }
                }
            }
        }
    }

    // --- Categorized List ---
    Repeater {
        model: ["core", "services", "utilities", "theming", "fonts", "livewallpaper", "optional"]
        delegate: ColumnLayout {
            Layout.fillWidth: true
            spacing: 12 * Appearance.effectiveScale
            
            // Category Header
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8 * Appearance.effectiveScale
                spacing: 8 * Appearance.effectiveScale
                
                Rectangle {
                    width: 4 * Appearance.effectiveScale
                    height: 16 * Appearance.effectiveScale
                    radius: 2 * Appearance.effectiveScale
                    color: Appearance.colors.colPrimary
                }
                
                StyledText {
                    text: {
                        switch(modelData) {
                            case "core": return "Core Components (Required)";
                            case "services": return "System Services";
                            case "utilities": return "Utility Tools";
                            case "theming": return "Theming & Appearance";
                            case "fonts": return "Required Fonts";
                            case "livewallpaper": return "Live Wallpaper Support";
                            case "optional": return "Optional Addons";
                            default: return modelData.toUpperCase();
                        }
                    }
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                    color: Appearance.colors.colPrimary
                    opacity: 0.8
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 12 * Appearance.effectiveScale
                columnSpacing: 12 * Appearance.effectiveScale

                Repeater {
                    model: SysCheckService.dependencyData.filter(d => d.category === modelData)
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 72 * Appearance.effectiveScale
                        radius: 20 * Appearance.effectiveScale
                        color: Appearance.m3colors.m3surfaceContainerHigh
                        border.width: 1 * Appearance.effectiveScale
                        border.color: modelData.installed ? "#81C995" : Appearance.colors.colError 

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true

                            onClicked: {
                                if (!modelData.installed) {
                                    Quickshell.execDetached(["kitty", "--hold", "-e", "paru", "-S", "--needed", modelData.name]);
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 20 * Appearance.effectiveScale
                                anchors.rightMargin: 20 * Appearance.effectiveScale
                                spacing: 16 * Appearance.effectiveScale

                                MaterialSymbol {
                                    text: modelData.installed ? "check_circle" : "cancel"
                                    iconSize: 28 * Appearance.effectiveScale
                                    color: modelData.installed ? "#81C995" : Appearance.colors.colError
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2 * Appearance.effectiveScale
                                    StyledText {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        font.pixelSize: Appearance.font.pixelSize.normal
                                        font.weight: Font.DemiBold
                                        color: Appearance.colors.colOnLayer1
                                        elide: Text.ElideRight
                                    }
                                    StyledText {
                                        Layout.fillWidth: true
                                        text: modelData.description || "System dependency"
                                        font.pixelSize: Appearance.font.pixelSize.smallest
                                        color: Appearance.colors.colSubtext
                                        elide: Text.ElideRight
                                    }
                                }

                                ColumnLayout {
                                    visible: !modelData.installed
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    spacing: 2 * Appearance.effectiveScale
                                    StyledText {
                                        text: "Not Installed"
                                        color: Appearance.colors.colError
                                        font.weight: Font.DemiBold
                                        font.pixelSize: Appearance.font.pixelSize.small
                                        Layout.alignment: Qt.AlignRight
                                    }
                                    StyledText {
                                        text: "Click to install"
                                        color: Appearance.colors.colError
                                        opacity: 0.8
                                        font.pixelSize: Appearance.font.pixelSize.smallest
                                        Layout.alignment: Qt.AlignRight
                                    }
                                }
                                
                                StyledText {
                                    visible: modelData.installed
                                    text: "Installed"
                                    color: "#81C995"
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    font.weight: Font.DemiBold
                                    font.pixelSize: Appearance.font.pixelSize.small
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

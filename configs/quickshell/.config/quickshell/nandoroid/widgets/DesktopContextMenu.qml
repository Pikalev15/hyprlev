import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../core"
import "../services"

/**
 * DesktopContextMenu.qml
 * A modern, premium right-click menu for the desktop.
 * Uses PanelWindow pattern for better focus and auto-close behavior.
 */
PanelWindow {
    id: root
    visible: false
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "nandoroid:desktop-context-menu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusionMode: ExclusionMode.Ignore
    
    property bool isClockMenu: false
    property real targetX: 0
    property real targetY: 0
    property real _mouseX: 0
    property real _mouseY: 0
    
    color: "transparent"

    // Click outside to close
    MouseArea {
        anchors.fill: parent
        onPressed: root.close()
    }

    Rectangle {
        id: menuContainer
        x: root.targetX
        y: root.targetY
        implicitWidth: Appearance.sizes.contextMenuWidth
        implicitHeight: menuLayout.implicitHeight + (12 * Appearance.effectiveScale)
        
        radius: Appearance.rounding.normal
        color: Appearance.colors.colLayer0
        border.color: Appearance.colors.colOutlineVariant
        border.width: Math.max(1, 1 * Appearance.effectiveScale)
        
        // Glassmorphism effect
        opacity: root.visible ? 0.98 : 0
        scale: root.visible ? 1 : 0.95
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: root.isClosing ? Appearance.animation.elementMoveExit.duration : Appearance.animation.elementMoveEnter.duration
                easing.bezierCurve: root.isClosing ? Appearance.animationCurves.emphasizedAccel : Appearance.animationCurves.expressiveDefaultSpatial
            }
        }
        
        Behavior on scale {
            NumberAnimation {
                duration: root.isClosing ? Appearance.animation.elementMoveExit.duration : Appearance.animation.elementMoveEnter.duration
                easing.bezierCurve: root.isClosing ? Appearance.animationCurves.emphasizedAccel : Appearance.animationCurves.expressiveDefaultSpatial
            }
        }

        // Prevent clicks on the menu from closing it
        MouseArea {
            anchors.fill: parent
            onPressed: (mouse) => mouse.accepted = true
        }

        ColumnLayout {
            id: menuLayout
            anchors.fill: parent
            anchors.margins: 6 * Appearance.effectiveScale
            spacing: 2 * Appearance.effectiveScale

            // --- Clock Specific Items ---
            MenuItem {
                visible: root.isClockMenu
                menuText: Config.options.appearance.clock.locked ? "Unlock Clock Position" : "Lock Clock Position"
                menuIcon: Config.options.appearance.clock.locked ? "lock_open" : "lock"
                onClicked: {
                    Config.options.appearance.clock.locked = !Config.options.appearance.clock.locked
                    root.close()
                }
            }

            MenuItem {
                visible: root.isClockMenu
                menuText: "Clock Settings"
                menuIcon: "schedule"
                onClicked: {
                    GlobalStates.settingsPageIndex = 4 // Wallpaper & Style
                    SearchRegistry.currentSearch = "" 
                    SearchRegistry.currentSearch = "Clock Style"
                    GlobalStates.settingsOpen = true
                    root.close()
                }
            }

            // --- General Desktop Items ---
            MenuItem {
                visible: !root.isClockMenu
                menuText: "Search (Spotlight)"
                menuIcon: "search"
                onClicked: {
                    GlobalStates.spotlightOpen = true
                    root.close()
                }
            }

            MenuItem {
                visible: !root.isClockMenu
                menuText: "Overview"
                menuIcon: "grid_view"
                onClicked: {
                    GlobalStates.overviewOpen = true
                    root.close()
                }
            }

            MenuItem {
                visible: !root.isClockMenu
                menuText: "Wallpaper & Styles"
                menuIcon: "palette"
                onClicked: {
                    GlobalStates.settingsPageIndex = 4 // Wallpaper & Style
                    GlobalStates.settingsOpen = true
                    root.close()
                }
            }
            
            MenuItem {
                visible: !root.isClockMenu
                menuText: "Dashboard"
                menuIcon: "dashboard"
                onClicked: {
                    GlobalStates.dashboardOpen = true
                    root.close()
                }
            }

            // Separator
            Rectangle {
                visible: !root.isClockMenu
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(1, 1 * Appearance.effectiveScale)
                Layout.leftMargin: 12 * Appearance.effectiveScale
                Layout.rightMargin: 12 * Appearance.effectiveScale
                color: Appearance.colors.colOutlineVariant
                opacity: 0.3
            }

            MenuItem {
                visible: !root.isClockMenu
                menuText: "System Monitor"
                menuIcon: "monitoring"
                onClicked: {
                    GlobalStates.systemMonitorOpen = true
                    root.close()
                }
            }
            
            MenuItem {
                visible: !root.isClockMenu
                menuText: "Terminal"
                menuIcon: "terminal"
                onClicked: {
                    terminalProcess.running = true
                    root.close()
                }
            }

            MenuItem {
                visible: !root.isClockMenu
                menuText: "Lock Screen"
                menuIcon: "lock"
                onClicked: {
                    GlobalStates.screenLocked = true
                    root.close()
                }
            }
        }
    }

    Process {
        id: terminalProcess
        command: ["kitty"]
    }

    // Helper component for menu items
    component MenuItem : RippleButton {
        id: itemRoot
        property string menuText: ""
        property string menuIcon: ""
        
        Layout.fillWidth: true
        Layout.preferredHeight: Appearance.sizes.contextMenuItemHeight
        
        buttonRadius: Appearance.rounding.small
        colBackground: "transparent"
        
        contentItem: RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12 * Appearance.effectiveScale
            anchors.rightMargin: 12 * Appearance.effectiveScale
            spacing: 12 * Appearance.effectiveScale
            
            MaterialSymbol {
                text: itemRoot.menuIcon
                iconSize: Appearance.sizes.iconSize * 0.9
                color: Appearance.colors.colOnLayer0
            }
            
            StyledText {
                text: itemRoot.menuText
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer0
                Layout.fillWidth: true
            }
        }
    }

    // Animation state
    property bool isClosing: false

    Timer {
        id: hideTimer
        interval: Appearance.animation.elementMoveExit.duration
        onTriggered: {
            root.visible = false;
            root.isClosing = false;
            GlobalStates.desktopContextMenuOpen = false;
        }
    }

    function openAt(mouseX, mouseY, isClock) {
        hideTimer.stop();
        isClosing = false;
        isClockMenu = isClock;
        root._mouseX = mouseX;
        root._mouseY = mouseY;
        root.visible = true;
        GlobalStates.desktopContextMenuOpen = true;
        
        Qt.callLater(() => {
            if (!root.visible) return;
            const screenWidth = root.screen.width;
            const screenHeight = root.screen.height;
            const menuWidth = Appearance.sizes.contextMenuWidth;
            const menuHeight = menuLayout.implicitHeight + (12 * Appearance.effectiveScale);
            
            // Constrain to screen
            root.targetX = Math.min(root._mouseX, screenWidth - menuWidth - 10 * Appearance.effectiveScale);
            if (root._mouseY + menuHeight > screenHeight - 10 * Appearance.effectiveScale) {
                root.targetY = root._mouseY - menuHeight;
            } else {
                root.targetY = root._mouseY;
            }
            root.targetY = Math.max(10 * Appearance.effectiveScale, root.targetY);
            
            menuContainer.opacity = 0.98;
            menuContainer.scale = 1;
        });
    }

    function close() {
        if (!visible || isClosing) return;
        isClosing = true;
        menuContainer.opacity = 0;
        menuContainer.scale = 0.95;
        hideTimer.start();
    }

    signal menuClosed()
    onVisibleChanged: {
        if (!visible) {
            menuContainer.opacity = 0;
            menuContainer.scale = 0.95;
            menuClosed();
        }
    }

    HyprlandFocusGrab {
        id: focusGrab
        active: root.visible && !root.isClosing
        windows: [root]
        onCleared: root.close()
    }
}

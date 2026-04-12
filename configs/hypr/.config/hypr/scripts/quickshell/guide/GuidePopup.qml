import QtQuick
import QtQuick.Window
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: root
    focus: true

    // --- Responsive Scaling Logic ---
    Scaler {
        id: scaler
        currentWidth: Screen.width
    }
    
    function s(val) { 
        return scaler.s(val); 
    }

    // -------------------------------------------------------------------------
    // KEYBOARD SHORTCUTS & NAVIGATION
    // -------------------------------------------------------------------------
    Keys.onEscapePressed: {
        closeSequence.start();
        event.accepted = true;
    }
    Keys.onTabPressed: {
        currentTab = (currentTab + 1) % tabNames.length;
        event.accepted = true;
    }
    Keys.onBacktabPressed: {
        currentTab = (currentTab - 1 + tabNames.length) % tabNames.length;
        event.accepted = true;
    }
    
    Keys.onLeftPressed: {
        if (currentTab === 1) {
            if (selectedModuleIndex > 0) {
                selectedModuleIndex--;
                modulesList.positionViewAtIndex(selectedModuleIndex, ListView.Contain);
            }
            event.accepted = true;
        }
    }
    Keys.onRightPressed: {
        if (currentTab === 1) {
            if (selectedModuleIndex < modulesDataModel.count - 1) {
                selectedModuleIndex++;
                modulesList.positionViewAtIndex(selectedModuleIndex, ListView.Contain);
            }
            event.accepted = true;
        }
    }
    Keys.onReturnPressed: {
        if (currentTab === 1) {
            let target = modulesDataModel.get(selectedModuleIndex).target;
            Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/qs_manager.sh", "toggle", target]);
            event.accepted = true;
        }
    }
    Keys.onEnterPressed: { Keys.onReturnPressed(event); }

    MatugenColors { id: _theme }
    
    // -------------------------------------------------------------------------
    // COLORS
    // -------------------------------------------------------------------------
    readonly property color base: _theme.base
    readonly property color mantle: _theme.mantle
    readonly property color crust: _theme.crust
    readonly property color text: _theme.text
    readonly property color subtext0: _theme.subtext0
    readonly property color subtext1: _theme.subtext1
    readonly property color surface0: _theme.surface0
    readonly property color surface1: _theme.surface1
    readonly property color surface2: _theme.surface2
    readonly property color overlay0: _theme.overlay0
    
    readonly property color mauve: _theme.mauve
    readonly property color pink: _theme.pink
    readonly property color blue: _theme.blue
    readonly property color sapphire: _theme.sapphire
    readonly property color green: _theme.green
    readonly property color peach: _theme.peach
    readonly property color yellow: _theme.yellow
    readonly property color red: _theme.red

    property real colorBlend: 0.0
    SequentialAnimation on colorBlend {
        loops: Animation.Infinite; running: true
        NumberAnimation { to: 1.0; duration: 15000; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0.0; duration: 15000; easing.type: Easing.InOutSine }
    }
    property color ambientPurple: Qt.tint(root.mauve, Qt.rgba(root.pink.r, root.pink.g, root.pink.b, colorBlend))
    property color ambientBlue: Qt.tint(root.blue, Qt.rgba(root.sapphire.r, root.sapphire.g, root.sapphire.b, colorBlend))

    // -------------------------------------------------------------------------
    // SYSTEM INFO PROPERTIES & FETCHER
    // -------------------------------------------------------------------------
    property string sysUser: "Loading..."
    property string sysHost: "Loading..."
    property string sysOS: "Loading..."
    property string sysKernel: "Loading..."
    property string sysCPU: "Loading..."
    property string sysGPU: "Loading..."

    Process {
        id: sysInfoProc
        command: ["bash", "-c", "echo \"$(whoami)|$(hostname)|$(uname -r)|$(cat /etc/os-release | grep '^PRETTY_NAME=' | cut -d'=' -f2 | tr -d '\"')|$(grep -m1 'model name' /proc/cpuinfo | cut -d':' -f2 | xargs)|$(lspci 2>/dev/null | grep -iE 'vga|3d|display' | tail -n1 | cut -d':' -f3 | xargs)\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let line = this.text.trim();
                let parts = line.split("|");
                if (parts.length >= 6) {
                    root.sysUser = parts[0];
                    root.sysHost = parts[1];
                    root.sysKernel = parts[2];
                    root.sysOS = parts[3];
                    root.sysCPU = parts[4];
                    root.sysGPU = parts[5] ? parts[5] : "Integrated Graphics";
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // STATE MANAGEMENT & DATA
    // -------------------------------------------------------------------------
    property int currentTab: 0
    property int selectedModuleIndex: 0
    property var tabNames: ["System", "Modules", "Keybinds", "Matugen", "Weather"]
    property var tabIcons: ["", "󰣆", "󰌌", "󰏘", "󰖐"]

    property real introBase: 0.0
    property real introSidebar: 0.0
    property real introContent: 0.0

    ListModel { id: dynamicKeybindsModel }
    
    ListModel {
        id: modulesDataModel
        ListElement { title: "Calendar & Weather"; target: "calendar"; icon: ""; desc: "Dual-sync calendar with live \nOpenWeatherMap integration."; preview: "previews/preview_calendar.png" }
        ListElement { title: "Media & Lyrics"; target: "music"; icon: "󰎆"; desc: "PlayerCtl integration, Cava \nvisualizer, and live lyrics."; preview: "previews/preview_music.png" }
        ListElement { title: "Battery & Power"; target: "battery"; icon: "󰁹"; desc: "Uptime tracking, power profiles, \nand battery health metrics."; preview: "previews/preview_battery.png" }
        ListElement { title: "Network Hub"; target: "network"; icon: "󰤨"; desc: "Wi-Fi and Bluetooth connection \nmanagement via nmcli/bluez."; preview: "previews/preview_network.png" }
        ListElement { title: "FocusTime"; target: "focustime"; icon: "󰄉"; desc: "Built-in Pomodoro timer daemon \nwith session tracking."; preview: "previews/preview_focustime.png" }
        ListElement { title: "Volume Mixer"; target: "volume"; icon: "󰕾"; desc: "Pipewire integration for I/O \nvolume and stream routing."; preview: "previews/preview_volume.png" }
        ListElement { title: "Wallpaper Picker"; target: "wallpaper"; icon: ""; desc: "Live awww backend rendering \nwith Matugen color generation."; preview: "previews/preview_wallpaper.png" }
        ListElement { title: "Monitors"; target: "monitors"; icon: "󰍹"; desc: "Quick display management."; preview: "previews/preview_monitors.png" }
        ListElement { title: "Stewart AI"; target: "stewart"; icon: "󰚩"; desc: "Voice assistant integration.\n(Reserved for future, currently disabled)"; preview: "previews/preview_stewart.png" }
    }
                
    function buildKeybinds() {
        dynamicKeybindsModel.clear();
        let binds = [
            { k1: "SUPER", k2: "RETURN", action: "Open Terminal (Kitty)", cmd: "kitty" },
            { k1: "SUPER", k2: "D", action: "App Launcher (Drun)", cmd: "bash ~/.config/hypr/scripts/rofi_show.sh drun" },
            { k1: "ALT", k2: "TAB", action: "Window Switcher", cmd: "bash ~/.config/hypr/scripts/rofi_show.sh window" },
            { k1: "SUPER", k2: "C", action: "Clipboard History", cmd: "bash ~/.config/hypr/scripts/rofi_clipboard.sh" },
            { k1: "SUPER", k2: "F", action: "Open Firefox", cmd: "firefox" },
            { k1: "SUPER", k2: "E", action: "Open Nautilus", cmd: "nautilus" },
            { k1: "ALT", k2: "F4", action: "Close Active Window/Widget", cmd: "bash -c 'if hyprctl activewindow | grep -q \"title: qs-master\"; then ~/.config/hypr/scripts/qs_manager.sh close; else hyprctl dispatch killactive; fi'" },
            { k1: "SUPER+SHIFT", k2: "F", action: "Toggle Floating", cmd: "hyprctl dispatch togglefloating" },
            { k1: "SUPER", k2: "L", action: "Lock Screen", cmd: "bash ~/.config/hypr/scripts/lock.sh" },
            { k1: "PRINT", k2: "", action: "Screenshot", cmd: "bash ~/.config/hypr/scripts/screenshot.sh" },
            { k1: "SHIFT", k2: "PRINT", action: "Screenshot (Edit)", cmd: "bash ~/.config/hypr/scripts/screenshot.sh --edit" },
            { k1: "ALT+SHIFT", k2: "", action: "Switch Keyboard Layout", cmd: "hyprctl switchxkblayout main next" },
            { k1: "SUPER", k2: "W", action: "Toggle Wallpaper Picker", cmd: "bash ~/.config/hypr/scripts/qs_manager.sh toggle wallpaper" },
            { k1: "SUPER", k2: "Q", action: "Toggle Music Widget", cmd: "bash ~/.config/hypr/scripts/qs_manager.sh toggle music" },
            { k1: "SUPER", k2: "B", action: "Toggle Battery Widget", cmd: "bash ~/.config/hypr/scripts/qs_manager.sh toggle battery" },
            { k1: "SUPER", k2: "S", action: "Toggle Calendar Widget", cmd: "bash ~/.config/hypr/scripts/qs_manager.sh toggle calendar" },
            { k1: "SUPER", k2: "N", action: "Toggle Network Widget", cmd: "bash ~/.config/hypr/scripts/qs_manager.sh toggle network" },
            { k1: "SUPER", k2: "V", action: "Toggle Volume Widget", cmd: "bash ~/.config/hypr/scripts/qs_manager.sh toggle volume" },
            { k1: "SUPER", k2: "M", action: "Toggle Monitors Widget", cmd: "bash ~/.config/hypr/scripts/qs_manager.sh toggle monitors" },
            { k1: "SUPER+SHIFT", k2: "T", action: "Toggle FocusTime", cmd: "bash ~/.config/hypr/scripts/qs_manager.sh toggle focustime" },
            { k1: "SUPER+SHIFT", k2: "S", action: "Toggle Stewart AI", cmd: "bash ~/.config/hypr/scripts/qs_manager.sh toggle stewart" },
            { k1: "SUPER", k2: "A", action: "Toggle SwayNC Panel", cmd: "swaync-client -t -sw" },
            { k1: "SUPER", k2: "SPACE", action: "Play/Pause Media", cmd: "playerctl play-pause" },
            { k1: "Media", k2: "Play/Pause", action: "Play/Pause Media", cmd: "playerctl play-pause" },
            { k1: "Media", k2: "Vol Up/Down", action: "Adjust Volume", cmd: "swayosd-client --output-volume raise" },
            { k1: "Media", k2: "Mute", action: "Mute Volume", cmd: "swayosd-client --output-volume mute-toggle" },
            { k1: "Media", k2: "Mic Mute", action: "Mute Microphone", cmd: "swayosd-client --input-volume mute-toggle" },
            { k1: "Media", k2: "Brightness", action: "Adjust Brightness", cmd: "swayosd-client --brightness raise" },
            { k1: "CAPS", k2: "LOCK", action: "Caps Lock OSD", cmd: "swayosd-client --caps-lock" },
            { k1: "SUPER", k2: "ARROWS", action: "Move Focus", cmd: "hyprctl dispatch movefocus r" },
            { k1: "SUPER+CTRL", k2: "ARROWS", action: "Move Window", cmd: "hyprctl dispatch movewindow r" },
            { k1: "SUPER+SHIFT", k2: "ARROWS", action: "Resize Window", cmd: "hyprctl dispatch resizeactive 50 0" }
        ];
        for (let item of binds) { dynamicKeybindsModel.append(item); }
    }

    function loadWeatherConfig() {
        var xhr = new XMLHttpRequest();
        var path = "file://" + Quickshell.env("HOME") + "/.config/hypr/scripts/quickshell/calendar/.env";
        xhr.open("GET", path, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && (xhr.status === 200 || xhr.status === 0)) {
                var lines = xhr.responseText.split('\n');
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line.startsWith("OPENWEATHER_KEY=")) apiKeyInput.text = line.substring(16).trim();
                    else if (line.startsWith("OPENWEATHER_CITY_ID=")) cityIdInput.text = line.substring(20).trim();
                    else if (line.startsWith("OPENWEATHER_UNIT=")) weatherTab.selectedUnit = line.substring(17).trim();
                }
            }
        }
        xhr.send();
    }

    Component.onCompleted: {
        startupSequence.start();
        buildKeybinds();
        loadWeatherConfig();
    }

    ParallelAnimation {
        id: startupSequence
        NumberAnimation { target: root; property: "introBase"; from: 0.0; to: 1.0; duration: 900; easing.type: Easing.OutExpo }
        SequentialAnimation {
            PauseAnimation { duration: 150 }
            NumberAnimation { target: root; property: "introSidebar"; from: 0.0; to: 1.0; duration: 1000; easing.type: Easing.OutBack; easing.overshoot: 1.05 }
        }
        SequentialAnimation {
            PauseAnimation { duration: 250 }
            NumberAnimation { target: root; property: "introContent"; from: 0.0; to: 1.0; duration: 1100; easing.type: Easing.OutBack; easing.overshoot: 1.02 }
        }
    }

    SequentialAnimation {
        id: closeSequence
        ParallelAnimation {
            NumberAnimation { target: root; property: "introContent"; to: 0.0; duration: 150; easing.type: Easing.InExpo }
            NumberAnimation { target: root; property: "introSidebar"; to: 0.0; duration: 150; easing.type: Easing.InExpo }
        }
        NumberAnimation { target: root; property: "introBase"; to: 0.0; duration: 200; easing.type: Easing.InQuart }
        ScriptAction { script: Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/qs_manager.sh", "close"]) }
    }

    // -------------------------------------------------------------------------
    // BACKGROUND AMBIENCE
    // -------------------------------------------------------------------------
    Item {
        anchors.fill: parent
        opacity: introBase
        scale: 0.95 + (0.05 * introBase)

        Rectangle {
            anchors.fill: parent
            radius: root.s(16)
            color: root.base
            border.color: root.surface0
            border.width: 1
            clip: true

            property real time: 0
            NumberAnimation on time { from: 0; to: Math.PI * 2; duration: 20000; loops: Animation.Infinite; running: true }

            Rectangle {
                width: root.s(600); height: root.s(600); radius: root.s(300)
                x: parent.width * 0.6 + Math.cos(parent.time) * root.s(100)
                y: parent.height * 0.1 + Math.sin(parent.time * 1.5) * root.s(100)
                color: root.ambientPurple
                opacity: 0.04
                layer.enabled: true; layer.effect: MultiEffect { blurEnabled: true; blurMax: 80; blur: 1.0 }
            }

            Rectangle {
                width: root.s(700); height: root.s(700); radius: root.s(350)
                x: parent.width * 0.1 + Math.sin(parent.time * 0.8) * root.s(150)
                y: parent.height * 0.4 + Math.cos(parent.time * 1.2) * root.s(100)
                color: root.ambientBlue
                opacity: 0.03
                layer.enabled: true; layer.effect: MultiEffect { blurEnabled: true; blurMax: 90; blur: 1.0 }
            }
        }
    }

    // -------------------------------------------------------------------------
    // MAIN LAYOUT
    // -------------------------------------------------------------------------
    RowLayout {
        anchors.fill: parent
        anchors.margins: root.s(20)
        spacing: root.s(20)

        // ==========================================
        // SIDEBAR
        // ==========================================
        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: root.s(220)
            radius: root.s(12)
            color: Qt.alpha(root.surface0, 0.4)
            border.color: root.surface1; border.width: 1
            
            opacity: introSidebar
            transform: Translate { x: root.s(-30) * (1.0 - introSidebar) }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.s(15)
                spacing: root.s(10)

                Item {
                    Layout.fillWidth: true; Layout.preferredHeight: root.s(60)
                    RowLayout {
                        anchors.fill: parent
                        spacing: root.s(12)
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            width: root.s(36); height: root.s(36); radius: root.s(10)
                            color: root.ambientPurple
                            Text { anchors.centerIn: parent; text: "󰣇"; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(20); color: root.base }
                        }
                        ColumnLayout {
                            Layout.alignment: Qt.AlignVCenter
                            spacing: root.s(2)
                            Text { text: "Imperative"; font.family: "JetBrains Mono"; font.weight: Font.Black; font.pixelSize: root.s(15); color: root.text; Layout.alignment: Qt.AlignLeft }
                            Text { text: "v1.0.14"; font.family: "JetBrains Mono"; font.pixelSize: root.s(11); color: root.subtext0; Layout.alignment: Qt.AlignLeft }
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.alpha(root.surface1, 0.5); Layout.bottomMargin: root.s(10) }

                Repeater {
                    model: root.tabNames.length
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.s(44)
                        radius: root.s(8)
                        
                        property bool isActive: root.currentTab === index
                        color: isActive ? root.surface1 : (tabMa.containsMouse ? Qt.alpha(root.surface1, 0.5) : "transparent")
                        Behavior on color { ColorAnimation { duration: 150 } }

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: root.s(15); spacing: root.s(12)
                            Item {
                                Layout.preferredWidth: root.s(24); Layout.alignment: Qt.AlignVCenter
                                Text { anchors.centerIn: parent; text: root.tabIcons[index]; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(18); color: parent.parent.parent.isActive ? root.ambientPurple : root.subtext0; Behavior on color { ColorAnimation{duration:150} } }
                            }
                            Text { text: root.tabNames[index]; font.family: "JetBrains Mono"; font.weight: parent.parent.isActive ? Font.Bold : Font.Medium; font.pixelSize: root.s(13); color: parent.parent.isActive ? root.text : root.subtext0; Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; Behavior on color { ColorAnimation{duration:150} } }
                        }
                        
                        Rectangle {
                            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                            width: root.s(3); height: parent.isActive ? root.s(20) : 0; radius: root.s(2)
                            color: root.ambientPurple
                            Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                        }

                        MouseArea {
                            id: tabMa
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTab = index
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: root.s(44); radius: root.s(8)
                    color: closeHover.containsMouse ? Qt.alpha(root.red, 0.1) : "transparent"
                    border.color: closeHover.containsMouse ? root.red : root.surface1
                    border.width: 1
                    scale: closeHover.pressed ? 0.95 : (closeHover.containsMouse ? 1.02 : 1.0)
                    
                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Item {
                        anchors.centerIn: parent
                        width: arrowText.implicitWidth; height: arrowText.implicitHeight
                        Text { 
                            id: arrowText
                            text: "" 
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: root.s(16)
                            color: closeHover.containsMouse ? root.red : root.subtext0
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                    MouseArea { id: closeHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: closeSequence.start() }
                }
            }
        }

        // ==========================================
        // CONTENT AREA
        // ==========================================
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            opacity: introContent
            scale: 0.95 + (0.05 * introContent)
            transform: Translate { y: root.s(20) * (1.0 - introContent) }

            // ------------------------------------------
            // TAB 0: SYSTEM OVERVIEW
            // ------------------------------------------
            Item {
                anchors.fill: parent
                visible: root.currentTab === 0
                opacity: visible ? 1.0 : 0.0
                property real slideY: visible ? 0 : root.s(10)
                Behavior on slideY { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
                transform: Translate { y: slideY }
                Behavior on opacity { NumberAnimation { duration: 250 } }

                ListModel {
                    id: systemDataModel
                    ListElement { pkg: "Hyprland"; role: "Wayland Compositor"; icon: ""; clr: "blue"; link: "https://hyprland.org/" }
                    ListElement { pkg: "Quickshell"; role: "UI Framework"; icon: "󰣆"; clr: "mauve"; link: "https://git.outfoxxed.me/outfoxxed/quickshell" }
                    ListElement { pkg: "Matugen"; role: "Theme Engine"; icon: "󰏘"; clr: "peach"; link: "https://github.com/InioX/matugen" }
                    ListElement { pkg: "Rofi Wayland"; role: "App Launcher"; icon: ""; clr: "green"; link: "https://github.com/lbonn/rofi" }
                    ListElement { pkg: "Kitty"; role: "Terminal Emulator"; icon: "󰄛"; clr: "yellow"; link: "https://sw.kovidgoyal.net/kitty/" }
                    ListElement { pkg: "SwayOSD / NC"; role: "Overlays & Notifs"; icon: "󰂚"; clr: "pink"; link: "https://github.com/ErikReider/SwayOSD" }
                }

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: root.s(20); spacing: root.s(20)

                    // ENHANCED DEVICE INFO BLOCK
                    Rectangle {
                        id: sysBox
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.s(180) // Increased height to prevent clipping
                        radius: root.s(16)
                        color: sysBoxMa.containsMouse ? Qt.alpha(root.surface0, 0.7) : Qt.alpha(root.surface0, 0.4)
                        border.color: sysBoxMa.containsMouse ? root.ambientBlue : root.surface1; border.width: 1
                        clip: true
                        
                        Behavior on color { ColorAnimation { duration: 300 } }
                        Behavior on border.color { ColorAnimation { duration: 300 } }

                        // Animated Background Blobs for depth
                        Rectangle {
                            width: root.s(250); height: root.s(250); radius: root.s(125)
                            x: sysBoxMa.containsMouse ? parent.width * 0.7 : parent.width * 0.8
                            y: -root.s(50)
                            color: root.ambientBlue
                            opacity: 0.15
                            layer.enabled: true; layer.effect: MultiEffect { blurEnabled: true; blurMax: 80; blur: 1.0 }
                            Behavior on x { NumberAnimation { duration: 800; easing.type: Easing.OutExpo } }
                        }
                        
                        Rectangle {
                            width: root.s(200); height: root.s(200); radius: root.s(100)
                            x: sysBoxMa.containsMouse ? root.s(50) : -root.s(50)
                            y: root.s(20)
                            color: root.ambientPurple
                            opacity: 0.15
                            layer.enabled: true; layer.effect: MultiEffect { blurEnabled: true; blurMax: 80; blur: 1.0 }
                            Behavior on x { NumberAnimation { duration: 800; easing.type: Easing.OutExpo } }
                        }

                        RowLayout {
                            anchors.fill: parent; anchors.margins: root.s(20); spacing: root.s(30)

                            // Avatar Section
                            Item {
                                Layout.preferredWidth: root.s(100)
                                Layout.preferredHeight: root.s(100)
                                
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: root.s(100); height: root.s(100); radius: root.s(50)
                                    color: "transparent"
                                    border.color: Qt.alpha(root.ambientPurple, sysBoxMa.containsMouse ? 0.8 : 0.3); border.width: root.s(3)
                                    scale: sysBoxMa.containsMouse ? 1.05 : 1.0
                                    
                                    Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
                                    Behavior on border.color { ColorAnimation { duration: 300 } }
                                    
                                    RotationAnimation on rotation { from: 0; to: 360; duration: 15000; loops: Animation.Infinite; running: true }
                                }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: root.s(84); height: root.s(84); radius: root.s(42)
                                    color: root.surface0
                                    Text { 
                                        anchors.centerIn: parent; text: ""; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(42); color: root.text
                                        scale: sysBoxMa.containsMouse ? 1.1 : 1.0
                                        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
                                    }
                                }
                            }

                            // Info Section
                            ColumnLayout {
                                Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: root.s(8)
                                
                                Text { text: root.sysUser; font.family: "JetBrains Mono"; font.weight: Font.Black; font.pixelSize: root.s(24); color: root.text }
                                Text { text: "@" + root.sysHost; font.family: "JetBrains Mono"; font.pixelSize: root.s(14); color: root.subtext0 }
                                
                                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.alpha(root.surface1, 0.5); Layout.topMargin: root.s(5); Layout.bottomMargin: root.s(5) }

                                RowLayout {
                                    spacing: root.s(15)
                                    RowLayout { 
                                        spacing: root.s(6)
                                        Text { text: ""; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(16); color: root.blue }
                                        Text { text: root.sysOS; font.family: "JetBrains Mono"; font.weight: Font.Medium; font.pixelSize: root.s(12); color: root.subtext0 } 
                                    }
                                    RowLayout { 
                                        spacing: root.s(6)
                                        Text { text: ""; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(16); color: root.peach }
                                        Text { text: root.sysKernel; font.family: "JetBrains Mono"; font.weight: Font.Medium; font.pixelSize: root.s(12); color: root.subtext0 } 
                                    }
                                }
                                RowLayout {
                                    spacing: root.s(15)
                                    RowLayout { 
                                        spacing: root.s(6)
                                        Text { text: ""; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(16); color: root.green }
                                        Text { text: root.sysCPU; font.family: "JetBrains Mono"; font.weight: Font.Medium; font.pixelSize: root.s(12); color: root.subtext0; elide: Text.ElideRight; Layout.maximumWidth: root.s(220) } 
                                    }
                                    RowLayout { 
                                        spacing: root.s(6)
                                        Text { text: "󰢮"; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(16); color: root.yellow }
                                        Text { text: root.sysGPU; font.family: "JetBrains Mono"; font.weight: Font.Medium; font.pixelSize: root.s(12); color: root.subtext0; elide: Text.ElideRight; Layout.maximumWidth: root.s(220) } 
                                    }
                                }
                            }
                        }
                        MouseArea { id: sysBoxMa; anchors.fill: parent; hoverEnabled: true }
                    }

                    // AUTHOR BLOCK (Moved down, smaller profile)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.s(60)
                        radius: root.s(10)
                        color: authorMa.containsMouse ? Qt.alpha(root.surface1, 0.6) : Qt.alpha(root.surface0, 0.4)
                        border.color: authorMa.containsMouse ? root.mauve : root.surface1; border.width: 1
                        scale: authorMa.pressed ? 0.98 : (authorMa.containsMouse ? 1.01 : 1.0)
                        
                        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        RowLayout {
                            anchors.fill: parent; anchors.margins: root.s(15); spacing: root.s(15)

                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                width: root.s(32); height: root.s(32); radius: root.s(8)
                                color: root.surface0; border.color: root.surface2; border.width: 1
                                Text { anchors.centerIn: parent; text: ""; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(20); color: root.text }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignVCenter; spacing: root.s(2)
                                Text { text: "System Config by"; font.family: "JetBrains Mono"; font.pixelSize: root.s(10); color: root.subtext0; font.weight: Font.Medium }
                                Row {
                                    spacing: root.s(1)
                                    Repeater {
                                        model: [ { l: "i", c: root.red }, { l: "l", c: root.peach }, { l: "y", c: root.yellow }, { l: "a", c: root.green }, { l: "m", c: root.sapphire }, { l: "i", c: root.blue }, { l: "r", c: root.mauve }, { l: "o", c: root.pink } ]
                                        Text {
                                            text: modelData.l; font.family: "JetBrains Mono"; font.weight: Font.Black; font.pixelSize: root.s(14); color: modelData.c
                                            property real hoverOffset: authorMa.containsMouse ? root.s(-3) : 0
                                            transform: Translate { y: hoverOffset }
                                            Behavior on hoverOffset { NumberAnimation { duration: 300 + (index * 35); easing.type: Easing.OutBack } }
                                        }
                                    }
                                }
                            }
                            Item { Layout.fillWidth: true }
                            
                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                width: root.s(28); height: root.s(28); radius: root.s(6)
                                color: authorMa.containsMouse ? root.surface1 : "transparent"
                                Text { anchors.centerIn: parent; text: ""; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(14); color: authorMa.containsMouse ? root.mauve : root.subtext0; Behavior on color { ColorAnimation { duration: 150 } } }
                            }
                        }
                        MouseArea {
                            id: authorMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["xdg-open", "https://github.com/ilyamiro/nixos-configuration"])
                        }
                    }

                    Text { text: "System Architecture"; font.family: "JetBrains Mono"; font.weight: Font.Black; font.pixelSize: root.s(24); color: root.text; Layout.alignment: Qt.AlignVCenter; Layout.topMargin: root.s(5) }
                    
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        rowSpacing: root.s(15); columnSpacing: root.s(15)

                        Repeater {
                            model: systemDataModel
                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: root.s(60); radius: root.s(10)
                                color: sysCardMa.containsMouse ? Qt.alpha(root[model.clr], 0.1) : Qt.alpha(root.surface0, 0.4)
                                border.color: sysCardMa.containsMouse ? root[model.clr] : root.surface1; border.width: 1
                                scale: sysCardMa.pressed ? 0.98 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
                                Behavior on color { ColorAnimation { duration: 200 } }
                                Behavior on border.color { ColorAnimation { duration: 200 } }
                                
                                Item {
                                    anchors.fill: parent; anchors.margins: root.s(10)
                                    Item {
                                        id: sysIconBox
                                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                                        width: root.s(36); height: root.s(36)
                                        Text { anchors.centerIn: parent; text: model.icon; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(22); color: root[model.clr] }
                                    }
                                    Column {
                                        anchors.left: sysIconBox.right; anchors.leftMargin: root.s(15); anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; spacing: root.s(2)
                                        Text { text: model.pkg; font.family: "JetBrains Mono"; font.weight: Font.Bold; font.pixelSize: root.s(14); color: root.text }
                                        Text { text: model.role; font.family: "JetBrains Mono"; font.pixelSize: root.s(11); color: root.subtext0 }
                                    }
                                }
                                MouseArea { id: sysCardMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["xdg-open", model.link]) }
                            }
                        }
                    }
                    Item { Layout.fillHeight: true }
                }
            }

            // ------------------------------------------
            // TAB 1: MODULES (FLUID CROSSFADE OVERHAUL)
            // ------------------------------------------
            Item {
                anchors.fill: parent
                visible: root.currentTab === 1
                opacity: visible ? 1.0 : 0.0
                property real slideY: visible ? 0 : root.s(10)
                Behavior on slideY { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
                transform: Translate { y: slideY }
                Behavior on opacity { NumberAnimation { duration: 250 } }

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: root.s(20); spacing: root.s(20)

                    // --- HEADER & PLAY BUTTON ---
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: root.s(4)
                            Text { text: "Interactive Modules"; font.family: "JetBrains Mono"; font.weight: Font.Black; font.pixelSize: root.s(28); color: root.text }
                            Text { text: "Use arrow keys or select below to preview. Double-click or press Enter to toggle."; font.family: "JetBrains Mono"; font.pixelSize: root.s(13); color: root.subtext0 }
                        }
                        
                        Item { Layout.fillWidth: true } 

                        Rectangle {
                            Layout.preferredWidth: root.s(110)
                            Layout.preferredHeight: root.s(44)
                            radius: root.s(22)
                            color: launchMa.containsMouse ? Qt.alpha(root.ambientBlue, 0.9) : Qt.alpha(root.ambientBlue, 0.7)
                            border.color: root.ambientBlue; border.width: 1
                            scale: launchMa.pressed ? 0.95 : (launchMa.containsMouse ? 1.05 : 1.0)
                            
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                            Behavior on color { ColorAnimation { duration: 150 } }

                            RowLayout {
                                anchors.centerIn: parent; spacing: root.s(8)
                                Text { text: "󰐊"; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(20); color: root.base }
                                Text { text: "PLAY"; font.family: "JetBrains Mono"; font.weight: Font.Black; font.pixelSize: root.s(14); color: root.base }
                            }
                            
                            MouseArea {
                                id: launchMa
                                anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/qs_manager.sh", "toggle", modulesDataModel.get(root.selectedModuleIndex).target])
                            }
                        }
                    }
                    
                    // --- TOP AREA: DUAL-IMAGE FLUID PREVIEW ---
                    Rectangle {
                        id: previewContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: root.s(12)
                        color: root.surface0
                        border.color: root.surface2
                        border.width: 1
                        clip: true

                        property string targetSource: modulesDataModel.get(root.selectedModuleIndex).preview ? Qt.resolvedUrl(modulesDataModel.get(root.selectedModuleIndex).preview) : ""

                        // Perfectly seamless dual-image crossfade logic
                        onTargetSourceChanged: {
                            baseImage.source = overlayImage.source;  // Freeze old image on base layer
                            overlayImage.opacity = 0.0;              // Hide top layer instantly
                            overlayImage.source = targetSource;      // Load new image on top layer
                            fadeAnim.restart();                      // Smoothly fade it in over the base layer
                        }

                        Image {
                            id: baseImage
                            anchors.fill: parent
                            anchors.margins: 0
                            fillMode: Image.PreserveAspectCrop
                            verticalAlignment: Image.AlignTop // Added to fix top cutoff
                            horizontalAlignment: Image.AlignHCenter
                            smooth: true
                            mipmap: true
                            asynchronous: true
                        }

                        Image {
                            id: overlayImage
                            anchors.fill: parent
                            anchors.margins: 0
                            fillMode: Image.PreserveAspectCrop
                            verticalAlignment: Image.AlignTop // Added to fix top cutoff
                            horizontalAlignment: Image.AlignHCenter
                            smooth: true
                            mipmap: true
                            asynchronous: true
                            
                            NumberAnimation on opacity {
                                id: fadeAnim
                                to: 1.0
                                duration: 350
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    // --- BOTTOM AREA: HORIZONTAL SELECTOR LIST ---
                    ListView {
                        id: modulesList
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.s(90)
                        orientation: ListView.Horizontal
                        spacing: root.s(15)
                        clip: true
                        model: modulesDataModel
                        currentIndex: root.selectedModuleIndex
                        
                        highlightMoveDuration: 250
                        
                        delegate: Rectangle {
                            width: root.s(220)
                            height: root.s(90)
                            radius: root.s(12)
                            
                            property bool isSelected: index === root.selectedModuleIndex
                            
                            color: isSelected ? root.surface1 : (modMa.containsMouse ? Qt.alpha(root.surface1, 0.5) : Qt.alpha(root.surface0, 0.4))
                            border.color: isSelected ? root.ambientBlue : (modMa.containsMouse ? root.surface2 : root.surface1)
                            border.width: isSelected ? 2 : 1
                            
                            scale: isSelected ? 1.0 : (modMa.pressed ? 0.96 : (modMa.containsMouse ? 1.02 : 1.0))
                            
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on border.color { ColorAnimation { duration: 200 } }

                            ColumnLayout {
                                anchors.fill: parent; anchors.margins: root.s(12); spacing: root.s(5)
                                RowLayout {
                                    spacing: root.s(10)
                                    Rectangle {
                                        Layout.alignment: Qt.AlignVCenter
                                        width: root.s(28); height: root.s(28); radius: root.s(6); color: Qt.alpha(root.base, 0.5)
                                        Text { anchors.centerIn: parent; text: model.icon; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(14); color: isSelected ? root.ambientBlue : root.text }
                                    }
                                    Text { 
                                        text: model.title; font.family: "JetBrains Mono"; font.weight: Font.Bold; font.pixelSize: root.s(12)
                                        color: root.text; Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
                                        elide: Text.ElideRight 
                                    }
                                }
                                Text {
                                    text: model.desc; font.family: "JetBrains Mono"; font.pixelSize: root.s(10); color: root.subtext0
                                    Layout.alignment: Qt.AlignLeft; Layout.fillWidth: true; Layout.fillHeight: true
                                    wrapMode: Text.WordWrap; elide: Text.ElideRight
                                }
                            }
                            
                            MouseArea { 
                                id: modMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor 
                                onClicked: {
                                    root.selectedModuleIndex = index;
                                    modulesList.positionViewAtIndex(index, ListView.Contain);
                                }
                                onDoubleClicked: {
                                    root.selectedModuleIndex = index;
                                    Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/qs_manager.sh", "toggle", model.target])
                                }
                            }
                        }
                    }
                }
            }

            // ------------------------------------------
            // TAB 2: KEYBINDS
            // ------------------------------------------
            Item {
                anchors.fill: parent
                visible: root.currentTab === 2
                opacity: visible ? 1.0 : 0.0
                property real slideY: visible ? 0 : root.s(10)
                Behavior on slideY { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
                transform: Translate { y: slideY }
                Behavior on opacity { NumberAnimation { duration: 250 } }

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: root.s(20); spacing: root.s(20)

                    Text { text: "Navigation & Control"; font.family: "JetBrains Mono"; font.weight: Font.Black; font.pixelSize: root.s(28); color: root.text; Layout.alignment: Qt.AlignVCenter }
                    Text { text: "Click any row below to instantly execute the keybind command."; font.family: "JetBrains Mono"; font.pixelSize: root.s(14); color: root.subtext0; Layout.alignment: Qt.AlignVCenter }
                    
                    ScrollView {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        contentWidth: availableWidth
                        clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        
                        GridLayout {
                            width: parent.width; columns: 2; rowSpacing: root.s(10); columnSpacing: root.s(15)
                            
                            Rectangle {
                                Layout.columnSpan: 2
                                Layout.fillWidth: true; Layout.preferredHeight: root.s(60); radius: root.s(8)
                                color: Qt.alpha(root.surface0, 0.4)
                                border.color: root.surface1; border.width: 1

                                RowLayout {
                                    anchors.fill: parent; anchors.margins: root.s(10); spacing: root.s(10)
                                    
                                    Text { text: "Workspaces (SUPER + 1-9)"; font.family: "JetBrains Mono"; font.weight: Font.Bold; font.pixelSize: root.s(13); color: root.text; Layout.alignment: Qt.AlignVCenter }
                                    Item { Layout.fillWidth: true }
                                    
                                    Repeater {
                                        model: 9
                                        Rectangle {
                                            property int wsNum: index + 1
                                            Layout.preferredWidth: root.s(32); Layout.preferredHeight: root.s(32); radius: root.s(6)
                                            color: wsMa.containsMouse ? root.surface1 : root.surface0
                                            border.color: wsMa.containsMouse ? root.peach : "transparent"; border.width: 1
                                            Text { anchors.centerIn: parent; text: parent.wsNum; font.family: "JetBrains Mono"; font.weight: Font.Bold; font.pixelSize: root.s(12); color: root.peach }
                                            
                                            MouseArea {
                                                id: wsMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                onClicked: Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/qs_manager.sh", wsNum.toString()])
                                            }
                                        }
                                    }
                                }
                            }

                            Repeater {
                                model: dynamicKeybindsModel
                                Rectangle {
                                    Layout.fillWidth: true; Layout.preferredHeight: root.s(46); radius: root.s(8)
                                    color: bindMa.containsMouse ? root.surface1 : Qt.alpha(root.surface0, 0.4)
                                    border.color: bindMa.containsMouse ? root.peach : "transparent"
                                    border.width: 1
                                    scale: bindMa.pressed ? 0.98 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }

                                    RowLayout {
                                        anchors.fill: parent; anchors.margins: root.s(10); spacing: root.s(15)
                                        
                                        Item {
                                            Layout.preferredWidth: root.s(220)
                                            Layout.minimumWidth: root.s(220)
                                            Layout.maximumWidth: root.s(220)
                                            Layout.fillHeight: true
                                            Row {
                                                anchors.verticalCenter: parent.verticalCenter; spacing: root.s(8)
                                                Rectangle { 
                                                    width: k1Text.implicitWidth + root.s(16); height: root.s(26); radius: root.s(4); color: root.surface0; border.color: root.surface2; border.width: 1
                                                    Text { id: k1Text; anchors.centerIn: parent; text: model.k1; font.family: "JetBrains Mono"; font.weight: Font.Bold; font.pixelSize: root.s(11); color: root.peach }
                                                }
                                                Text { text: "+"; font.family: "JetBrains Mono"; font.pixelSize: root.s(12); color: root.overlay0; visible: model.k2 !== ""; anchors.verticalCenter: parent.verticalCenter }
                                                Rectangle { 
                                                    width: k2Text.implicitWidth + root.s(16); height: root.s(26); radius: root.s(4); color: root.surface0; border.color: root.surface2; border.width: 1; visible: model.k2 !== ""
                                                    Text { id: k2Text; anchors.centerIn: parent; text: model.k2; font.family: "JetBrains Mono"; font.weight: Font.Bold; font.pixelSize: root.s(11); color: root.peach }
                                                }
                                            }
                                        }
                                        
                                        Text { 
                                            text: model.action
                                            font.family: "JetBrains Mono"
                                            font.pixelSize: root.s(13)
                                            color: root.text
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            horizontalAlignment: Text.AlignLeft
                                            elide: Text.ElideRight
                                            clip: true
                                        }
                                    }
                                    MouseArea {
                                        id: bindMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                        onClicked: Quickshell.execDetached(["bash", "-c", model.cmd])
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ------------------------------------------
            // TAB 3: MATUGEN ENGINE (ANIMATED SHOWCASE)
            // ------------------------------------------
            Item {
                anchors.fill: parent
                visible: root.currentTab === 3
                opacity: visible ? 1.0 : 0.0
                property real slideY: visible ? 0 : root.s(10)
                Behavior on slideY { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
                transform: Translate { y: slideY }
                Behavior on opacity { NumberAnimation { duration: 250 } }

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: root.s(20); spacing: root.s(20)

                    Text { text: "Theming Engine"; font.family: "JetBrains Mono"; font.weight: Font.Black; font.pixelSize: root.s(28); color: root.text; Layout.alignment: Qt.AlignVCenter }
                    
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: root.s(160); radius: root.s(12)
                        color: Qt.alpha(root.surface0, 0.4); border.color: root.ambientPurple; border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent; anchors.margins: root.s(20); spacing: root.s(20)
                            
                            Item { Layout.fillWidth: true } 

                            ColumnLayout {
                                Layout.alignment: Qt.AlignVCenter; spacing: root.s(8)
                                Rectangle { 
                                    Layout.alignment: Qt.AlignHCenter; width: root.s(60); height: root.s(60); radius: root.s(10); color: root.surface1
                                    Text { anchors.centerIn: parent; text: ""; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(28); color: root.text } 
                                }
                                Text { text: "Wallpaper"; font.family: "JetBrains Mono"; font.weight: Font.Bold; font.pixelSize: root.s(12); color: root.text; Layout.alignment: Qt.AlignHCenter }
                            }
                            
                            // Animated Data Flow 1
                            Item {
                                Layout.preferredWidth: root.s(60); Layout.preferredHeight: root.s(20); Layout.alignment: Qt.AlignVCenter
                                Repeater {
                                    model: 3
                                    Item {
                                        width: parent.width; height: parent.height
                                        Rectangle {
                                            width: root.s(6); height: root.s(6); radius: root.s(3)
                                            color: [root.mauve, root.peach, root.blue][index]
                                            y: parent.height / 2 - root.s(3)
                                            SequentialAnimation on x {
                                                loops: Animation.Infinite; running: root.currentTab === 3
                                                PauseAnimation { duration: index * 400 }
                                                NumberAnimation { from: 0; to: parent.width; duration: 1200; easing.type: Easing.InOutSine }
                                            }
                                            SequentialAnimation on opacity {
                                                loops: Animation.Infinite; running: root.currentTab === 3
                                                PauseAnimation { duration: index * 400 }
                                                NumberAnimation { from: 0; to: 1; duration: 300 }
                                                PauseAnimation { duration: 600 }
                                                NumberAnimation { from: 1; to: 0; duration: 300 }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // Pulsing Matugen Core
                            Rectangle {
                                width: root.s(180); height: root.s(90); radius: root.s(12); color: root.base; border.color: root.ambientPurple
                                Layout.alignment: Qt.AlignVCenter
                                
                                SequentialAnimation on border.width {
                                    loops: Animation.Infinite; running: root.currentTab === 3
                                    NumberAnimation { from: root.s(1); to: root.s(4); duration: 1000; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: root.s(4); to: root.s(1); duration: 1000; easing.type: Easing.InOutSine }
                                }

                                ColumnLayout {
                                    anchors.centerIn: parent; spacing: root.s(8)
                                    Text { text: "Matugen Core"; font.family: "JetBrains Mono"; font.weight: Font.Black; font.pixelSize: root.s(15); color: root.ambientPurple; Layout.alignment: Qt.AlignHCenter }
                                    RowLayout {
                                        spacing: root.s(4); Layout.alignment: Qt.AlignHCenter
                                        Repeater {
                                            model: [root.red, root.peach, root.yellow, root.green, root.blue, root.mauve]
                                            Rectangle { 
                                                Layout.alignment: Qt.AlignVCenter; width: root.s(12); height: root.s(12); radius: root.s(6); color: modelData 
                                                SequentialAnimation on scale {
                                                    loops: Animation.Infinite; running: root.currentTab === 3
                                                    PauseAnimation { duration: index * 150 }
                                                    NumberAnimation { to: 1.3; duration: 300; easing.type: Easing.OutQuart }
                                                    NumberAnimation { to: 1.0; duration: 400; easing.type: Easing.OutQuart }
                                                    PauseAnimation { duration: 1000 }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Animated Data Flow 2
                            Item {
                                Layout.preferredWidth: root.s(60); Layout.preferredHeight: root.s(20); Layout.alignment: Qt.AlignVCenter
                                Repeater {
                                    model: 3
                                    Item {
                                        width: parent.width; height: parent.height
                                        Rectangle {
                                            width: root.s(6); height: root.s(6); radius: root.s(3)
                                            color: [root.green, root.yellow, root.pink][index]
                                            y: parent.height / 2 - root.s(3)
                                            SequentialAnimation on x {
                                                loops: Animation.Infinite; running: root.currentTab === 3
                                                PauseAnimation { duration: index * 400 }
                                                NumberAnimation { from: 0; to: parent.width; duration: 1200; easing.type: Easing.InOutSine }
                                            }
                                            SequentialAnimation on opacity {
                                                loops: Animation.Infinite; running: root.currentTab === 3
                                                PauseAnimation { duration: index * 400 }
                                                NumberAnimation { from: 0; to: 1; duration: 300 }
                                                PauseAnimation { duration: 600 }
                                                NumberAnimation { from: 1; to: 0; duration: 300 }
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.alignment: Qt.AlignVCenter; spacing: root.s(8)
                                Rectangle { 
                                    Layout.alignment: Qt.AlignHCenter; width: root.s(60); height: root.s(60); radius: root.s(10); color: root.surface1
                                    Text { anchors.centerIn: parent; text: "󰏘"; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(28); color: root.text } 
                                }
                                Text { text: "Templates"; font.family: "JetBrains Mono"; font.weight: Font.Bold; font.pixelSize: root.s(12); color: root.text; Layout.alignment: Qt.AlignHCenter }
                            }

                            Item { Layout.fillWidth: true } 
                        }
                    }

                    Text { text: "When you change wallpapers, Matugen extracts the dominant colors and injects them directly into these configuration files in real-time:"; font.family: "JetBrains Mono"; font.pixelSize: root.s(13); color: root.subtext0; Layout.fillWidth: true; wrapMode: Text.WordWrap; Layout.alignment: Qt.AlignVCenter }

                    GridLayout {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        columns: 3; rowSpacing: root.s(10); columnSpacing: root.s(10)
                        
                        Repeater {
                            model: [
                                { f: "kitty-colors.conf", i: "󰄛", c: "yellow" },
                                { f: "nvim-colors.lua", i: "", c: "green" },
                                { f: "rofi.rasi", i: "", c: "blue" },
                                { f: "cava-colors.ini", i: "󰎆", c: "mauve" },
                                { f: "sddm-colors.qml", i: "󰍃", c: "peach" },
                                { f: "swaync/osd.css", i: "󰂚", c: "pink" }
                            ]
                            Rectangle {
                                Layout.fillWidth: true; Layout.preferredHeight: root.s(45); radius: root.s(8)
                                color: tplMa.containsMouse ? Qt.alpha(root[modelData.c], 0.1) : root.surface0
                                border.color: tplMa.containsMouse ? root[modelData.c] : "transparent"
                                border.width: 1
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                RowLayout {
                                    anchors.fill: parent; anchors.margins: root.s(10); spacing: root.s(10)
                                    Item {
                                        Layout.preferredWidth: root.s(24); Layout.alignment: Qt.AlignVCenter
                                        Text { anchors.centerIn: parent; text: modelData.i; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(16); color: root[modelData.c] }
                                    }
                                    Text { text: modelData.f; font.family: "JetBrains Mono"; font.weight: Font.Medium; font.pixelSize: root.s(12); color: root.text; Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter }
                                }
                                MouseArea { id: tplMa; anchors.fill: parent; hoverEnabled: true }
                            }
                        }
                    }
                }
            }

            // ------------------------------------------
            // TAB 4: WEATHER API & SETTINGS
            // ------------------------------------------
            Item {
                id: weatherTab
                anchors.fill: parent
                visible: root.currentTab === 4
                opacity: visible ? 1.0 : 0.0
                property real slideY: visible ? 0 : root.s(10)
                Behavior on slideY { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }
                transform: Translate { y: slideY }
                Behavior on opacity { NumberAnimation { duration: 250 } }

                property string selectedUnit: "metric"
                property bool apiKeyVisible: false

                function saveWeatherConfig() {
                    var file = Quickshell.env("HOME") + "/.config/hypr/scripts/quickshell/calendar/.env";
                    var cmds = [
                        "mkdir -p $(dirname " + file + ")",
                        "echo '# OpenWeather API Configuration (OVERWRITE, not add)' > " + file,
                        "echo 'OPENWEATHER_KEY=" + apiKeyInput.text + "' >> " + file,
                        "echo 'OPENWEATHER_CITY_ID=" + cityIdInput.text + "' >> " + file,
                        "echo 'OPENWEATHER_UNIT=" + weatherTab.selectedUnit + "' >> " + file,
                        "notify-send 'Weather' 'API configuration saved successfully!'"
                    ];
                    
                    var finalCmd = cmds.join(" && ");
                    Quickshell.execDetached(["bash", "-c", finalCmd]);
                }

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: root.s(20); spacing: root.s(15)

                    Text { text: "Weather Configuration"; font.family: "JetBrains Mono"; font.weight: Font.Black; font.pixelSize: root.s(28); color: root.text; Layout.alignment: Qt.AlignVCenter }
                    
                    Text { 
                        text: "To use the weather widget, please enter your OpenWeatherMap API Key.\nThen, search for your city's exact City ID on OpenWeatherMap and enter it below."
                        font.family: "JetBrains Mono"; font.pixelSize: root.s(13); color: root.subtext0
                        Layout.fillWidth: true; wrapMode: Text.WordWrap; Layout.alignment: Qt.AlignVCenter 
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: root.s(46); radius: root.s(8)
                        color: root.surface0; border.color: apiKeyInput.activeFocus ? root.blue : root.surface2; border.width: 1
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                        
                        RowLayout {
                            anchors.fill: parent; anchors.margins: root.s(10); spacing: root.s(10)
                            Text { text: "󰌆"; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(18); color: root.subtext0 }
                            
                            TextInput {
                                id: apiKeyInput
                                Layout.fillWidth: true; Layout.fillHeight: true
                                verticalAlignment: TextInput.AlignVCenter
                                font.family: "JetBrains Mono"; font.pixelSize: root.s(13); color: root.text
                                clip: true; selectByMouse: true
                                
                                echoMode: weatherTab.apiKeyVisible ? TextInput.Normal : TextInput.Password
                                passwordCharacter: "•"
                                
                                Text { text: "Enter OpenWeather API Key..."; color: root.subtext0; visible: !parent.text && !parent.activeFocus; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                            }

                            Rectangle {
                                width: root.s(26); height: root.s(26); radius: root.s(4); color: "transparent"
                                Text { 
                                    anchors.centerIn: parent
                                    text: weatherTab.apiKeyVisible ? "󰈈" : "󰈉" 
                                    font.family: "Iosevka Nerd Font"
                                    font.pixelSize: root.s(18)
                                    color: eyeMa.containsMouse ? root.blue : root.subtext0
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                                MouseArea { id: eyeMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: weatherTab.apiKeyVisible = !weatherTab.apiKeyVisible }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: root.s(46); radius: root.s(8); Layout.topMargin: root.s(10)
                        color: root.surface0; border.color: cityIdInput.activeFocus ? root.peach : root.surface2; border.width: 1
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        TextInput {
                            id: cityIdInput
                            anchors.fill: parent; anchors.margins: root.s(10); verticalAlignment: TextInput.AlignVCenter
                            font.family: "JetBrains Mono"; font.pixelSize: root.s(13); color: root.text; clip: true; selectByMouse: true
                            Text { text: "City ID (e.g. 2624652)"; color: root.subtext0; visible: !parent.text && !parent.activeFocus; font: parent.font; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true; spacing: root.s(15); Layout.topMargin: root.s(10)
                        
                        Text { text: "Units:"; font.family: "JetBrains Mono"; font.weight: Font.Bold; font.pixelSize: root.s(13); color: root.text }
                        
                        RowLayout {
                            spacing: root.s(5)
                            Repeater {
                                model: ["metric", "imperial", "standard"]
                                Rectangle {
                                    Layout.preferredWidth: root.s(80); Layout.preferredHeight: root.s(32); radius: root.s(6)
                                    color: weatherTab.selectedUnit === modelData ? Qt.alpha(root.mauve, 0.2) : "transparent"
                                    border.color: weatherTab.selectedUnit === modelData ? root.mauve : root.surface1; border.width: 1
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }

                                    Text { 
                                        anchors.centerIn: parent; text: modelData
                                        font.family: "JetBrains Mono"; font.pixelSize: root.s(11); font.capitalization: Font.Capitalize
                                        color: weatherTab.selectedUnit === modelData ? root.mauve : root.subtext0 
                                    }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: weatherTab.selectedUnit = modelData }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true; Layout.fillWidth: true }

                    RowLayout {
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }

                        Rectangle {
                            Layout.preferredWidth: root.s(160); Layout.preferredHeight: root.s(46); radius: root.s(8)
                            color: saveMa.containsMouse ? Qt.alpha(root.green, 0.8) : root.green
                            scale: saveMa.pressed ? 0.95 : (saveMa.containsMouse ? 1.02 : 1.0)
                            
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                            Behavior on color { ColorAnimation { duration: 150 } }

                            RowLayout {
                                anchors.centerIn: parent; spacing: root.s(8)
                                Text { text: "󰆓"; font.family: "Iosevka Nerd Font"; font.pixelSize: root.s(18); color: root.base }
                                Text { text: "Save Config"; font.family: "JetBrains Mono"; font.weight: Font.Black; font.pixelSize: root.s(14); color: root.base }
                            }
                            MouseArea { id: saveMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: weatherTab.saveWeatherConfig() }
                        }
                    }
                }
            }
        }
    }
}

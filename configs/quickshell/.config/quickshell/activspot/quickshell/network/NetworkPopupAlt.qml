import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Window
import QtCore
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: window
    focus: true

    // --- Responsive Scaling Logic ---
    Scaler {
        id: scaler
        currentWidth: Screen.width
    }
    
    function s(val) { 
        return scaler.s(val); 
    }

    Settings {
        id: cache
        category: "QS_DesktopNetworkWidget"
        property string lastEthJson: ""
    }

    Component.onCompleted: {
        if (cache.lastEthJson !== "") processEthJson(cache.lastEthJson);
        introState = 1.0;
    }

    function playSfx(filename) {
        try {
            let rawUrl = Qt.resolvedUrl("sounds/" + filename).toString();
            let cleanPath = rawUrl;
            if (cleanPath.indexOf("file://") === 0) cleanPath = cleanPath.substring(7); 
            let cmd = "pw-play '" + cleanPath + "' 2>/dev/null || paplay '" + cleanPath + "' 2>/dev/null";
            Quickshell.execDetached(["sh", "-c", cmd]);
        } catch(e) {}
    }

    MatugenColors { id: _theme }

    readonly property color base: _theme.base
    readonly property color mantle: _theme.mantle
    readonly property color crust: _theme.crust
    readonly property color text: _theme.text
    readonly property color subtext0: _theme.subtext0
    readonly property color overlay0: _theme.overlay0
    readonly property color overlay1: _theme.overlay1
    readonly property color surface0: _theme.surface0
    readonly property color surface1: _theme.surface1
    readonly property color surface2: _theme.surface2
    
    readonly property color mauve: _theme.mauve
    readonly property color pink: _theme.pink
    readonly property color sapphire: _theme.sapphire
    readonly property color blue: _theme.blue
    readonly property color red: _theme.red
    readonly property color maroon: _theme.maroon
    readonly property color peach: _theme.peach

    readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/hypr/scripts/quickshell/network"
    
    readonly property color ethAccent: Qt.lighter(window.sapphire, 1.15) 
    readonly property color activeColor: window.ethAccent
    readonly property color activeGradientSecondary: Qt.darker(window.activeColor, 1.25)

    // Simplified connection logic
    property string ethDeviceName: "" // Stores interface name (e.g. enp5s0)
    property bool ethPowerPending: false
    property string expectedEthPower: ""
    property string ethPower: "off"
    property var ethConnected: null
    readonly property bool isEthConn: !!window.ethConnected

    readonly property bool currentPower: window.ethPower === "on"
    readonly property bool currentPowerPending: window.ethPowerPending
    readonly property bool currentConn: window.isEthConn
    
    // Core synchronization 
    property var currentCore: window.ethConnected
    property real activeCoreCount: currentConn ? 1 : 0
    property real smoothedActiveCoreCount: activeCoreCount
    Behavior on smoothedActiveCoreCount { NumberAnimation { duration: 1000; easing.type: Easing.InOutExpo } }

    Timer { id: ethPendingReset; interval: 8000; onTriggered: { window.ethPowerPending = false; window.expectedEthPower = ""; } }

    onCurrentConnChanged: updateInfoNodes()

    ListModel { id: infoListModel }

    function syncModel(listModel, dataArray) {
        for (let i = listModel.count - 1; i >= 0; i--) {
            let id = listModel.get(i).id;
            let found = false;
            for (let j = 0; j < dataArray.length; j++) {
                if (id === dataArray[j].id) { found = true; break; }
            }
            if (!found) listModel.remove(i);
        }
        
        for (let i = 0; i < dataArray.length && i < 30; i++) {
            let d = dataArray[i];
            let foundIdx = -1;
            for (let j = i; j < listModel.count; j++) {
                if (listModel.get(j).id === d.id) { foundIdx = j; break; }
            }
            
            let obj = {
                id: d.id || "", name: d.name || "", icon: d.icon || "", action: d.action || "",
                isInfoNode: d.isInfoNode || false, isActionable: d.isActionable || false, 
                cmdStr: d.cmdStr || "", parentIndex: 0
            };

            if (foundIdx === -1) {
                listModel.insert(i, obj);
            } else {
                if (foundIdx !== i) { listModel.move(foundIdx, i, 1); }
                for (let key in obj) { 
                    if (listModel.get(i)[key] !== obj[key]) {
                        listModel.setProperty(i, key, obj[key]); 
                    }
                }
            }
        }
    }

    function updateInfoNodes() {
        let nodes = [];
        let obj = window.currentCore;
        
        if (window.currentConn && obj) {
            nodes.push({ id: "ip", name: obj.ip || "No IP", icon: "󰩟", action: "IP Address", isInfoNode: true });
            nodes.push({ id: "spd", name: obj.speed || "Unknown", icon: "󰓅", action: "Link Speed", isInfoNode: true });
            nodes.push({ id: "mac", name: obj.mac || "Unknown", icon: "󰒋", action: "MAC Address", isInfoNode: true });
        }
        window.syncModel(infoListModel, nodes);
    }

    function processEthJson(textData) {
        if (textData === "") return;
        try {
            let data = JSON.parse(textData);
            
            let fetchedDevice = data.device || "";
            if (fetchedDevice !== "") window.ethDeviceName = fetchedDevice;

            let fetchedPower = data.power || "off";
            
            if (window.ethPowerPending) {
                window.ethPower = window.expectedEthPower; 
                if (fetchedPower === window.expectedEthPower) {
                    window.ethPowerPending = false; 
                    ethPendingReset.stop();
                }
            } else {
                window.ethPower = fetchedPower;
                window.expectedEthPower = "";
            }

            let newConnected = data.connected;
            if (JSON.stringify(window.ethConnected) !== JSON.stringify(newConnected)) {
                if (!window.isEthConn && newConnected) window.playSfx("connect.wav");
                window.ethConnected = newConnected;
                updateInfoNodes();
            }
        } catch(e) {}
    }

    Process {
        id: ethPoller
        command: ["bash", window.scriptsDir + "/eth_panel_logic.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                cache.lastEthJson = this.text.trim();
                processEthJson(cache.lastEthJson);
            }
        }
    }
    
    Timer {
        interval: 3000
        running: true; repeat: true
        onTriggered: { 
            if (!ethPoller.running) ethPoller.running = true; 
        }
    }

    property real globalOrbitAngle: 0
    NumberAnimation on globalOrbitAngle {
        from: 0; to: Math.PI * 2; duration: 200000; loops: Animation.Infinite; running: true
    }


    property real introState: 0.0
    Behavior on introState { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }

    Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            radius: window.s(18)
            color: window.base
            border.color: window.surface0
            border.width: 1
            clip: true

            // Subtle ambient glow
            Rectangle {
                width: parent.width * 1.4; height: width; radius: width / 2
                anchors.right: parent.right; anchors.rightMargin: -width * 0.55
                anchors.top: parent.top; anchors.topMargin: -height * 0.55
                opacity: window.currentPower ? (window.currentConn ? 0.07 : 0.03) : 0.02
                color: window.activeColor
                Behavior on opacity { NumberAnimation { duration: 800 } }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: window.s(16)
                spacing: window.s(12)

                opacity: introState
                transform: Translate { y: window.s(8) * (1.0 - introState) }
                Behavior on opacity { NumberAnimation { duration: 300 } }

                // ─── Header: status icon + name/status + power toggle ───
                RowLayout {
                    Layout.fillWidth: true
                    spacing: window.s(10)

                    Rectangle {
                        width: window.s(42); height: window.s(42)
                        radius: window.s(12)
                        color: window.currentConn
                            ? Qt.alpha(window.activeColor, 0.15)
                            : (window.currentPower ? Qt.alpha(window.surface1, 0.6) : Qt.alpha(window.surface0, 0.4))
                        border.color: window.currentConn ? Qt.alpha(window.activeColor, 0.35) : window.surface1
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 400 } }
                        Behavior on border.color { ColorAnimation { duration: 400 } }

                        Text {
                            anchors.centerIn: parent
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: window.s(22)
                            color: window.currentConn ? window.activeColor
                                : (window.currentPower ? window.overlay0 : window.surface2)
                            text: window.currentConn ? "󰈀" : (window.currentPower ? "󰈁" : "󰈂")
                            Behavior on color { ColorAnimation { duration: 400 } }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: window.s(2)

                        Text {
                            Layout.fillWidth: true
                            text: window.currentCore ? window.currentCore.name
                                : (window.ethDeviceName !== "" ? window.ethDeviceName : "Ethernet")
                            font.family: "JetBrains Mono"; font.weight: Font.Black
                            font.pixelSize: window.s(15)
                            color: window.text
                            elide: Text.ElideRight
                        }
                        Text {
                            text: {
                                if (window.currentPowerPending)
                                    return window.expectedEthPower === "on" ? "Turning on..." : "Turning off..."
                                if (!window.currentPower) return "Offline"
                                return window.currentConn ? "Connected" : "Not connected"
                            }
                            font.family: "JetBrains Mono"
                            font.pixelSize: window.s(11)
                            color: window.currentConn ? window.activeColor
                                : (window.currentPower ? window.overlay0 : window.surface2)
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }
                    }

                    Rectangle {
                        width: window.s(34); height: window.s(34); radius: window.s(17)
                        color: window.currentPower ? window.activeColor : Qt.alpha(window.surface0, 0.8)
                        border.color: window.currentPowerPending ? window.activeColor
                            : (window.currentPower ? "transparent" : window.surface1)
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 300 } }
                        scale: pwrMa.pressed ? 0.88 : (pwrMa.containsMouse ? 1.08 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

                        Text {
                            id: pwrIcon
                            anchors.centerIn: parent
                            font.family: "Iosevka Nerd Font"
                            font.pixelSize: window.s(16)
                            color: window.currentPower ? window.crust : window.subtext0
                            text: window.currentPowerPending ? "󰑮" : ""
                            Behavior on color { ColorAnimation { duration: 300 } }

                            RotationAnimation {
                                target: pwrIcon; property: "rotation"
                                from: 0; to: 360; duration: 800
                                loops: Animation.Infinite; running: window.currentPowerPending
                                onRunningChanged: if (!running) pwrIcon.rotation = 0
                            }
                        }

                        MouseArea {
                            id: pwrMa
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (window.ethPowerPending) return;
                                window.expectedEthPower = window.ethPower === "on" ? "off" : "on";
                                window.ethPowerPending = true;
                                if (window.expectedEthPower === "on") window.playSfx("power_on.wav");
                                else window.playSfx("power_off.wav");
                                ethPendingReset.restart();
                                window.ethPower = window.expectedEthPower;
                                let targetDev = window.ethDeviceName !== "" ? window.ethDeviceName
                                    : (window.currentCore ? window.currentCore.id : "");
                                if (targetDev !== "") {
                                    if (window.expectedEthPower === "on")
                                        Quickshell.execDetached(["nmcli", "device", "connect", targetDev]);
                                    else
                                        Quickshell.execDetached(["nmcli", "device", "disconnect", targetDev]);
                                }
                                ethPoller.running = true;
                            }
                        }
                    }
                }

                // ─── Divider ───
                Rectangle {
                    Layout.fillWidth: true; height: 1
                    color: window.surface0; opacity: 0.9
                }

                // ─── Info rows (IP, Speed, MAC) ───
                Repeater {
                    model: infoListModel
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: window.s(34)
                        radius: window.s(9)
                        color: Qt.alpha(window.surface0, 0.5)
                        border.color: window.surface1; border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: window.s(10)
                            anchors.rightMargin: window.s(10)
                            spacing: window.s(8)

                            Text {
                                font.family: "Iosevka Nerd Font"; font.pixelSize: window.s(16)
                                color: Qt.alpha(window.activeColor, 0.85)
                                text: icon
                            }
                            Text {
                                font.family: "JetBrains Mono"; font.pixelSize: window.s(10)
                                color: window.overlay0; text: action
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                font.family: "JetBrains Mono"; font.weight: Font.Bold
                                font.pixelSize: window.s(12)
                                color: window.text; text: name
                                elide: Text.ElideLeft
                                Layout.maximumWidth: window.s(130)
                            }
                        }
                    }
                }

                // ─── Disconnect button ───
                Item {
                    id: disconnectBtn
                    Layout.fillWidth: true
                    height: window.s(36)
                    visible: window.currentConn && window.currentPower
                    opacity: visible ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 300 } }

                    property real fillLevel: 0.0
                    property bool triggered: false

                    Rectangle {
                        anchors.fill: parent; radius: window.s(9)
                        color: disconnMa.containsMouse ? Qt.alpha(window.red, 0.07) : "transparent"
                        border.color: disconnMa.containsMouse ? Qt.alpha(window.red, 0.45) : window.surface1
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 200 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        Rectangle {
                            anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom
                            width: parent.width * disconnectBtn.fillLevel
                            radius: window.s(9)
                            color: Qt.alpha(window.red, 0.18)
                        }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: window.s(7)
                        Text {
                            font.family: "Iosevka Nerd Font"; font.pixelSize: window.s(14)
                            color: disconnMa.containsMouse ? window.red : window.overlay0
                            text: "󰈂"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        Text {
                            font.family: "JetBrains Mono"; font.weight: Font.Medium; font.pixelSize: window.s(11)
                            color: disconnMa.containsMouse ? window.red : window.overlay0
                            text: disconnectBtn.fillLevel > 0.05 ? "Hold to disconnect..." : "Disconnect"
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    MouseArea {
                        id: disconnMa
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onPressed: { if (!disconnectBtn.triggered) { disconnDrain.stop(); disconnFill.start(); } }
                        onReleased: {
                            if (!disconnectBtn.triggered && disconnectBtn.fillLevel < 1.0) {
                                disconnFill.stop(); disconnDrain.start();
                            }
                        }
                    }

                    NumberAnimation {
                        id: disconnFill; target: disconnectBtn; property: "fillLevel"; to: 1.0
                        duration: 700 * (1.0 - disconnectBtn.fillLevel); easing.type: Easing.InSine
                        onFinished: {
                            disconnectBtn.triggered = true;
                            window.playSfx("disconnect.wav");
                            Quickshell.execDetached(["sh", "-c", "nmcli device disconnect '" + window.currentCore.id + "'"]);
                            disconnectBtn.fillLevel = 0.0;
                            disconnectBtn.triggered = false;
                            ethPoller.running = true;
                        }
                    }
                    NumberAnimation {
                        id: disconnDrain; target: disconnectBtn; property: "fillLevel"; to: 0.0
                        duration: 1000 * disconnectBtn.fillLevel; easing.type: Easing.OutQuad
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }
}
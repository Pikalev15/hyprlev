import QtQuick

// Pixel cat in the collapsed island pill.
// Style: solid silhouette + two eye-dots (like the reference sprite sheet).
// Poses: sit · blink · walk · sleep · alert
Item {
    id: root

    property bool  playing:      false
    property bool  notifActive:  false
    property bool  showQuestion: false
    property color catColor:    "#cdd6f4"   // light on dark bg
    property color eyeColor:    "#1e1e2e"   // dark eye dot on light body

    implicitWidth:  24
    implicitHeight: 24

    readonly property int ps: 3   // 8 art-px × 3 = 24 real px

    // ── 8×8 sprite frames ────────────────────────────────────
    // '#' = body (catColor)   'E' = eye (eyeColor)   ' ' = transparent

    // Front-facing sit, eyes open
    readonly property var fSit: [
        " ##  ## ",
        "########",
        "#E####E#",
        "########",
        "########",
        " ###### ",
        "  ####  ",
        "  ####  "
    ]
    // Eyes closed (blink — row 2 = solid body)
    readonly property var fBlink: [
        " ##  ## ",
        "########",
        "########",
        "########",
        "########",
        " ###### ",
        "  ####  ",
        "  ####  "
    ]
    // Side-view walk frame A (right paw forward) — flip for left direction
    readonly property var fWalkA: [
        " #     #",
        "########",
        "#E######",
        "########",
        "########",
        " ###### ",
        " # ## # ",
        "  #  #  "
    ]
    // Side-view walk frame B (legs alternate)
    readonly property var fWalkB: [
        " #     #",
        "########",
        "#E######",
        "########",
        "########",
        " ###### ",
        "  ## #  ",
        "  #   # "
    ]
    // Sleeping / lying on side (no eye = closed)
    readonly property var fSleep: [
        "        ",
        " #      ",
        "########",
        "########",
        "########",
        "########",
        " ###### ",
        "       #"
    ]
    // Surprised wide eyes (notification)
    readonly property var fAlert: [
        " ##  ## ",
        "########",
        "#EE##EE#",
        "########",
        "########",
        " ###### ",
        "  ####  ",
        "  ####  "
    ]

    readonly property var sequences: ({
        "idle":  [fSit, fSit, fSit, fBlink],
        "walk":  [fWalkA, fWalkB],
        "sleep": [fSleep],
        "bop":   [fSit, fSit],
        "alert": [fAlert, fSit, fAlert, fSit]
    })

    // ── State ────────────────────────────────────────────────
    property string internalState: "idle"
    property string catState: notifActive ? "alert" : (playing ? "bop" : internalState)
    property int    frameIdx: 0
    property int    walkDir:  1    // 1 = right, -1 = left (flips sprite)

    // Vertical bop for music
    property real bopY: 0
    SequentialAnimation on bopY {
        running: root.catState === "bop"; loops: Animation.Infinite
        NumberAnimation { to: -2; duration: 260; easing.type: Easing.OutSine }
        NumberAnimation { to:  0; duration: 260; easing.type: Easing.InSine }
    }

    onCatStateChanged: { bopY = 0; frameIdx = 0; canvas.requestPaint(); }
    onCatColorChanged: canvas.requestPaint()
    onEyeColorChanged: canvas.requestPaint()

    // Transforms: flip direction (walk), then bop offset
    transform: [
        Scale   { xScale: root.catState === "walk" ? root.walkDir : 1; origin.x: 12 },
        Translate { y: root.bopY }
    ]

    // ── Canvas ───────────────────────────────────────────────
    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            var seq = root.sequences[root.catState];
            if (!seq) return;
            var sprite = seq[root.frameIdx % seq.length];
            if (!sprite) return;
            var p   = root.ps;
            var bdy = root.catColor.toString();
            var eye = root.eyeColor.toString();
            for (var row = 0; row < sprite.length; row++) {
                var line = sprite[row];
                for (var col = 0; col < line.length; col++) {
                    var ch = line[col];
                    if (ch === " ") continue;
                    ctx.fillStyle = (ch === "E") ? eye : bdy;
                    ctx.fillRect(col * p, row * p, p, p);
                }
            }
        }
    }

    // "?" pulse above cat when on notifs page
    Text {
        visible:        root.showQuestion && !root.notifActive
        text:           "?"
        font.family:    "JetBrains Mono"
        font.pixelSize: 9
        font.weight:    Font.Black
        color:          root.catColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:           parent.top
        anchors.bottomMargin:     2
        SequentialAnimation on opacity {
            running: root.showQuestion && !root.notifActive; loops: Animation.Infinite
            NumberAnimation { to: 1.0; duration: 450 }
            NumberAnimation { to: 0.2; duration: 450 }
        }
    }

    // "!" pulse above cat during notification
    Text {
        visible:        root.notifActive
        text:           "!"
        font.family:    "JetBrains Mono"
        font.pixelSize: 9
        font.weight:    Font.Black
        color:          root.catColor
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom:           parent.top
        anchors.bottomMargin:     2
        SequentialAnimation on opacity {
            running: root.notifActive; loops: Animation.Infinite
            NumberAnimation { to: 1.0; duration: 300 }
            NumberAnimation { to: 0.3; duration: 300 }
        }
    }

    // ── Frame ticker ─────────────────────────────────────────
    Timer {
        interval: root.catState === "bop"   ? 260 :
                  root.catState === "walk"  ? 200 :
                  root.catState === "alert" ? 220 :
                  root.catState === "sleep" ? 9999 : 500
        running: true; repeat: true
        onTriggered: {
            var seq = root.sequences[root.catState];
            root.frameIdx = (root.frameIdx + 1) % (seq ? seq.length : 1);
            canvas.requestPaint();
        }
    }

    // ── Idle state machine (sit → walk → sleep → …) ──────────
    Timer {
        id: stateTick
        running: true; repeat: false
        interval: 2500 + Math.random() * 3000
        onTriggered: {
            if (!root.notifActive && !root.playing) {
                var roll = Math.random();
                if (root.internalState === "idle") {
                    if (roll < 0.40) {
                        root.internalState = "walk";
                        root.walkDir = Math.random() < 0.5 ? 1 : -1;
                        interval = 1800 + Math.random() * 2500;
                    } else if (roll < 0.62) {
                        root.internalState = "sleep";
                        interval = 5000 + Math.random() * 7000;
                    } else {
                        interval = 2000 + Math.random() * 2500;
                    }
                } else {
                    root.internalState = "idle";
                    interval = 2500 + Math.random() * 3000;
                }
            } else {
                interval = 1500;
            }
            restart();
        }
    }
}

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Service providing session statistics like package counts and upgrades.
 */
Singleton {
    id: root

    property int packageCount: 0
    property int upgradeCount: 0

    Process {
        id: pkgProc
        command: ["bash", "-c", "pacman -Q | wc -l"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(this.text.trim());
                if (!isNaN(val)) root.packageCount = val;
            }
        }
    }

    Process {
        id: upgradeProc
        command: ["bash", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const val = parseInt(this.text.trim());
                if (!isNaN(val)) root.upgradeCount = val;
            }
        }
    }

    function update() {
        // Launches a terminal to perform the update. 
        // We try yay first, then pacman.
        Quickshell.execDetached(["bash", "-c", "kitty --title 'System Update' bash -c 'if command -v yay >/dev/null; then yay; else sudo pacman -Syu; fi; echo -e \"\\nDone. Press any key to exit.\"; read -n 1'"]);
    }

    Timer {
        id: refreshTimer
        interval: 600000 // 10 minutes
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            pkgProc.running = true;
            upgradeProc.running = true;
        }
    }

    // Refresh when dashboard opens to ensure fresh data
    Connections {
        target: GlobalStates
        function onDashboardOpenChanged() {
            if (GlobalStates.dashboardOpen) {
                pkgProc.running = true;
                upgradeProc.running = true;
            }
        }
    }
}

import Quickshell
import Quickshell.Io

Scope {
    Process {
        command: ["quickshell", "-p", "/home/lev15/.config/hypr/scripts/quickshell/Main.qml"]
        running: true
    }
    Process {
        command: ["quickshell", "-p", "/home/lev15/.config/hypr/scripts/quickshell/TopBar.qml"]
        running: true
    }
}

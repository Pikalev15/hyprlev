pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../core"

import "." 

Singleton {
    id: root

    property bool active: false
    readonly property string persistencePath: "~/.config/hypr/nandoroid/user_persistence.conf"

    // --- Wallpaper State for Gaming Mode ---
    property string _previousLiveWallpaperPath: ""
    property string _previousStaticWallpaperPath: ""
    property string _previousLayout: ""

    function toggle() {
        root.active = !root.active
        // Synchronize with Do Not Disturb
        Notifications.silent = root.active
        
        if (root.active) {
            // --- 1. HANDLE WALLPAPER (OPTIMIZATION) ---
            if (WallpaperEngineService.isRunning || Config.options.appearance.background.liveWallpaperPath !== "") {
                // Store the current state
                root._previousLiveWallpaperPath = Config.options.appearance.background.liveWallpaperPath;
                root._previousStaticWallpaperPath = Config.options.appearance.background.wallpaperPath;
                
                // 1. Stop the process
                WallpaperEngineService.stopInternal();
                
                // 2. Clear path in Config so Background.qml displays static wallpaper
                Config.options.appearance.background.liveWallpaperPath = "";
                
                // 3. Check and apply high quality screenshot
                screenshotCheckProc.running = true;
            }

            // --- 2. HANDLE HYPRLAND (PERFORMANCE) ---
            // Store current layout to restore it later
            if (typeof HyprlandData !== "undefined" && HyprlandData.activeWorkspace) {
                root._previousLayout = HyprlandData.activeWorkspace.tiledLayout || GlobalStates.hyprlandLayout || "dwindle";
            }

            const batchCmd = [
                "animations:enabled 0",
                "decoration:shadow:enabled 0",
                "decoration:blur:enabled 0",
                "general:gaps_in 0",
                "general:gaps_out 0",
                "general:border_size 1",
                "decoration:rounding 0",
                "general:allow_tearing 1"
            ];
            
            // Apply via hyprctl immediately
            Quickshell.execDetached(["bash", "-c", `hyprctl --batch "keyword ${batchCmd.join('; keyword ')}"`])
            
            // Persist to file
            const persistCmd = `sed -i '/animations:enabled/d; /decoration:shadow:enabled/d; /decoration:blur:enabled/d; /general:gaps_in/d; /general:gaps_out/d; /general:border_size/d; /decoration:rounding/d; /general:allow_tearing/d' ${root.persistencePath} 2>/dev/null || true; ` +
                batchCmd.map(c => `echo "${c.replace(' ', ' = ')}" >> ${root.persistencePath}`).join('; ');
            
            Quickshell.execDetached(["bash", "-c", persistCmd]);

        } else {
            // --- 1. REVERT WALLPAPER ---
            if (root._previousLiveWallpaperPath !== "") {
                // Restore live wallpaper path to Config
                Config.options.appearance.background.liveWallpaperPath = root._previousLiveWallpaperPath;
                
                // Restore static wallpaper path (reverting from temporary screenshot)
                if (root._previousStaticWallpaperPath !== "") {
                    Wallpapers.select(root._previousStaticWallpaperPath);
                }
                
                // Restart live wallpaper
                WallpaperEngineService.applyInternal(root._previousLiveWallpaperPath);
                
                // Reset state
                root._previousLiveWallpaperPath = "";
                root._previousStaticWallpaperPath = "";
            }

            // --- 2. REVERT HYPRLAND ---
            // Cleanup from persistence file BEFORE reload
            const cleanupCmd = `sed -i '/animations:enabled/d; /decoration:shadow:enabled/d; /decoration:blur:enabled/d; /general:gaps_in/d; /general:gaps_out/d; /general:border_size/d; /decoration:rounding/d; /general:allow_tearing/d' ${root.persistencePath} 2>/dev/null || true`;
            
            Quickshell.execDetached(["bash", "-c", `${cleanupCmd} && hyprctl reload`]);

            // Re-enforce other persistence (like layout) because reload wiped them
            const timer = Qt.createQmlObject('import QtQuick; Timer { interval: 800; repeat: false; }', root);
            timer.triggered.connect(() => {
                if (typeof HyprlandData !== 'undefined') {
                    // Restore layout explicitly if we saved it
                    if (root._previousLayout !== "") {
                        Quickshell.execDetached(["hyprctl", "keyword", "general:layout", root._previousLayout]);
                    }

                    const reapplyCmd = `cat ${root.persistencePath} 2>/dev/null | sed 's/ = / /g' | xargs -I {} hyprctl keyword {} || true`;
                    Quickshell.execDetached(["bash", "-c", reapplyCmd]);
                    HyprlandData.fetchInitialLayout();
                }
                timer.destroy();
            });
            timer.start();
        }
    }

    // Helper component to check screenshot file existence without TypeError
    Process {
        id: screenshotCheckProc
        command: ["test", "-s", WallpaperEngineService.screenshotPath]
        onExited: (code) => {
            if (code === 0) {
                // File exists and is not empty, use it!
                Wallpapers.select(WallpaperEngineService.screenshotPath);
            }
        }
    }

    function fetchActiveState() {
        fetchActiveStateProc.running = true
    }

    Process {
        id: fetchActiveStateProc
        running: true
        command: ["bash", "-c", `test "$(hyprctl getoption animations:enabled -j | jq ".int")" -eq 0`]
        onExited: (code) => {
            root.active = (code === 0)
        }
    }
}

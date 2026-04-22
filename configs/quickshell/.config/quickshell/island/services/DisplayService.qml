pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Service for managing monitor configurations via hyprctl.
 * Persists monitor settings to ~/.config/hypr/nandoroid/user_persistence.conf
 */
Singleton {
    id: root

    readonly property string persistencePath: "~/.config/hypr/nandoroid/user_persistence.conf"

    function setResolution(monitorName, resolution, refreshRate) {
        applyMonitorSettings({
            name: monitorName,
            resolution: resolution,
            refreshRate: refreshRate
        });
    }

    function setScale(monitorName, scale) {
        applyMonitorSettings({
            name: monitorName,
            scale: scale
        });
    }

    function setOrientation(monitorName, transform) {
        applyMonitorSettings({
            name: monitorName,
            transform: transform
        });
    }

    function setPosition(monitorName, x, y) {
        applyMonitorSettings({
            name: monitorName,
            x: x,
            y: y
        });
    }

    function applyMonitorSettings(opts) {
        const monitors = HyprlandData.monitors;
        const target = monitors.find(m => m.name === opts.name);
        
        if (!target && !opts.resolution && opts.x === undefined && !opts.mirror) return;

        const name = opts.name;
        
        // Handle Mirroring
        if (opts.mirror) {
            const mirrorCmd = `${name},preferred,auto,1,mirror,${opts.mirror}`;
            Quickshell.execDetached(["hyprctl", "keyword", "monitor", mirrorCmd]);
            persistMonitor(name, mirrorCmd);
            return;
        }

        const rawRes = opts.resolution || (target ? `${target.width}x${target.height}` : "preferred");
        const refresh = Math.round(opts.refreshRate || (target ? target.refreshRate : 60));
        
        let resCmd = rawRes;
        if (rawRes !== "preferred" && !rawRes.includes("@")) {
            resCmd = `${rawRes}@${refresh}`;
        }

        const x = opts.x !== undefined ? Math.round(opts.x) : (target ? target.x : 0);
        const y = opts.y !== undefined ? Math.round(opts.y) : (target ? target.y : 0);
        const pos = `${x}x${y}`;
        
        const scale = opts.scale !== undefined ? opts.scale : (target ? target.scale : 1.0);
        const transform = opts.transform !== undefined ? opts.transform : (target ? target.transform : 0);
        
        // Syntax: name,res@refresh,pos,scale
        let cmd = `${name},${resCmd},${pos},${scale.toFixed(2)}`;
        if (transform !== 0) {
            cmd += `,transform,${transform}`;
        }
        
        // Use full path or ensuring environment
        Quickshell.execDetached(["hyprctl", "keyword", "monitor", cmd]);
        persistMonitor(name, cmd);
    }

    function persistMonitor(monitorName, configString) {
        // Persist to file: remove existing monitor config for this name and add new one
        // We use a specific pattern to match the monitor name at the start of the line
        const cmd = `sed -i "/^monitor = ${monitorName},/d" ${root.persistencePath} 2>/dev/null || true; echo "monitor = ${configString}" >> ${root.persistencePath}`;
        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    function batchApply(allChanges) {
        for (const name in allChanges) {
            const opts = allChanges[name];
            opts.name = name;
            applyMonitorSettings(opts);
        }
    }
}

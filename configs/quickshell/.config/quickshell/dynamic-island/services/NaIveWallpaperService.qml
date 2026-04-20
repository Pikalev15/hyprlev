pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../core"
import "../core/functions" as Functions

/**
 * Service for interacting with na-ive wallpaper collection.
 */
Singleton {
    id: root

    property string wallpaperDir: Functions.FileUtils.trimFileProtocol(Directories.pictures) + "/Wallpapers"
    readonly property string nandoroidIcon: Directories.home.replace("file://", "") + "/.config/quickshell/nandoroid/assets/icons/NAnDoroid.svg"
    readonly property alias results: naiveModel
    property bool loading: false
    property string errorMessage: ""
    
    readonly property string baseUrl: "https://na-ive.github.io/wallpapers/"
    readonly property string jsonUrl: "https://raw.githubusercontent.com/na-ive/wallpapers/gh-pages/wallpapers.json"

    ListModel {
        id: naiveModel
    }

    signal fetchFinished()

    function fetch() {
        if (naiveModel.count > 0 && !root.errorMessage) return; // Cache results
        
        root.loading = true;
        root.errorMessage = "";
        naiveModel.clear();

        const xhr = new XMLHttpRequest();
        xhr.open("GET", root.jsonUrl);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                root.loading = false;
                if (xhr.status === 200) {
                    try {
                        const response = JSON.parse(xhr.responseText);
                        if (Array.isArray(response)) {
                            // Sort by mtime descending (newest first)
                            response.sort((a, b) => new Date(b.mtime) - new Date(a.mtime));
                            
                            const newItems = response.map(item => ({
                                "id": item.wallhaven_id || item.filename.split('.')[0],
                                "wallhaven_id": item.wallhaven_id || "",
                                "filename": item.filename,
                                "preview": root.baseUrl + item.thumbnail,
                                "full": root.baseUrl + item.filename,
                                "color": item.color || "#000000",
                                "is_naive": true
                            }));
                            
                            for (let i = 0; i < newItems.length; i++) {
                                naiveModel.append(newItems[i]);
                            }
                        }
                    } catch (e) {
                        console.error("[Na-ive] Parse error:", e);
                        root.errorMessage = "Failed to parse wallpaper list";
                    }
                } else {
                    root.errorMessage = "Server error (" + xhr.status + ")";
                }
                root.fetchFinished();
            }
        };
        xhr.onerror = function() {
            root.loading = false;
            root.errorMessage = "Network error. Check connection.";
            root.fetchFinished();
        };
        xhr.send();
    }

    function download(url, filename, apply = false) {
        const fullPath = root.wallpaperDir + "/" + filename;

        Quickshell.execDetached(["mkdir", "-p", root.wallpaperDir]);

        // Check if file exists
        const checkProc = createProcess.createObject(null, {
            command: ["sh", "-c", 'if [ -f "$1" ]; then exit 0; else exit 1; fi', "sh", fullPath]
        });
        
        checkProc.exited.connect((exitCode) => {
            if (exitCode === 0) {
                if (apply) {
                    if (GlobalStates.wallpaperSelectorTarget === "desktop") {
                        Wallpapers.select("file://" + fullPath);
                    } else {
                        Wallpapers.selectForLockscreen("file://" + fullPath);
                    }
                    root.sendNotification("Na-ive Wallpapers", "Already exists. Applied!");
                } else {
                    root.sendNotification("Na-ive Wallpapers", "Already downloaded: " + filename);
                }
                checkProc.destroy();
            } else {
                checkProc.destroy();
                if (apply) {
                    const p = createProcess.createObject(null, {
                        command: ["sh", "-c", 'curl -L "$1" -o "$2"', "sh", url, fullPath]
                    });
                    p.exited.connect((exitCode) => {
                        if (exitCode === 0) {
                            if (GlobalStates.wallpaperSelectorTarget === "desktop") {
                                Wallpapers.select("file://" + fullPath);
                            } else {
                                Wallpapers.selectForLockscreen("file://" + fullPath);
                            }
                            root.sendNotification("Na-ive Wallpapers", "Wallpaper applied successfully!");
                        } else {
                            root.sendNotification("Na-ive Wallpapers", "Download failed.");
                        }
                        p.destroy();
                    });
                    p.running = true;
                } else {
                    Quickshell.execDetached([
                        "sh", "-c", 
                        'curl -L "$1" -o "$2" && notify-send -a "NAnDoroid" -i "$3" -- "Na-ive Wallpapers" "Downloaded: $4"',
                        "sh", url, fullPath, root.nandoroidIcon, filename
                    ]);
                }
            }
        });
        checkProc.running = true;
    }

    function sendNotification(title, body) {
        Quickshell.execDetached([
            "notify-send", 
            "-a", "NAnDoroid", 
            "-i", root.nandoroidIcon, 
            "--", title, body
        ]);
    }

    Component {
        id: createProcess
        Process {}
    }
}

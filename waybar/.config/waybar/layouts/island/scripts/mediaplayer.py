#!/usr/bin/env python3
import subprocess
import json
import sys

def get_player_status():
    try:
        player = subprocess.run(
            ["playerctl", "-p", "spotify", "status"],
            capture_output=True, text=True
        ).stdout.strip()

        if player not in ["Playing", "Paused"]:
            print(json.dumps({"text": "", "tooltip": "", "class": "stopped"}))
            return

        artist = subprocess.run(
            ["playerctl", "-p", "spotify", "metadata", "artist"],
            capture_output=True, text=True
        ).stdout.strip()

        title = subprocess.run(
            ["playerctl", "-p", "spotify", "metadata", "title"],
            capture_output=True, text=True
        ).stdout.strip()

        icon = "󰎇" if player == "Playing" else "󰏤"
        text = f"{icon} {artist} - {title}"
        tooltip = f"Spotify: {artist} - {title}\nStatus: {player}"

        # truncate if too long
        if len(text) > 40:
            text = text[:37] + "..."

        print(json.dumps({
            "text": text,
            "tooltip": tooltip,
            "class": player.lower()
        }))

    except Exception as e:
        print(json.dumps({"text": "", "tooltip": str(e)}))

get_player_status()

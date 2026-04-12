#!/usr/bin/env bash

# Debounce
sleep 0.1

# Kill any child listening jobs on exit so we don't spawn infinite zombies
trap 'kill $(jobs -p) 2>/dev/null' EXIT

# Wrap each listener in a subshell that sleeps infinitely if the command fails.

# 1. Native Pipewire Volume Waiter (Bulletproof on Arch)
if command -v pw-mon &>/dev/null; then
    ( pw-mon 2>/dev/null | grep --line-buffered -E "changed|added|removed" | head -n 1 || sleep infinity ) &
else
    ( pactl subscribe 2>/dev/null | grep --line-buffered -E "Event 'change' on sink" | head -n 1 || sleep infinity ) &
fi

# 2. Native D-Bus Music Waiter (Never crashes, even if no players are open)
( dbus-monitor --session "type='signal',interface='org.freedesktop.DBus.Properties',path_namespace='/org/mpris/MediaPlayer2'" 2>/dev/null | grep --line-buffered "string" | head -n 1 || sleep infinity ) &

# 3. Network
( nmcli monitor 2>/dev/null | grep --line-buffered -E "connected|disconnected|unavailable|enabled|disabled" | head -n 1 || sleep infinity ) &

# 4. Bluetooth 
( dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',arg0='org.bluez.Device1'" 2>/dev/null | grep --line-buffered "interface" | head -n 1 || sleep infinity ) &

# 5. Battery
( udevadm monitor --subsystem-match=power_supply 2>/dev/null | grep --line-buffered "change" | head -n 1 || sleep infinity ) &

# 6. Workspaces
( socat -u UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - 2>/dev/null | grep --line-buffered "activelayout" | head -n 1 || sleep infinity ) &

# Failsafe: Force a silent UI refresh every 60 seconds just in case an event is missed
sleep 60 &

# Wait for the *first* background job to successfully complete an event
wait -n

# Output a signal to ensure Quickshell's StdioCollector registers the stream completion
echo "trigger"

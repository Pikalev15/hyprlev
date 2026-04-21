#!/usr/bin/env bash
ACTION="${1:-toggle}"
STEP="${2:-5}"

case "$ACTION" in
    up)     pactl set-sink-volume @DEFAULT_SINK@ +${STEP}% ;;
    down)   pactl set-sink-volume @DEFAULT_SINK@ -${STEP}% ;;
    mute)   pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
    mic)    pactl set-source-mute @DEFAULT_SOURCE@ toggle ;;
esac

MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -c "yes" || echo 0)
if [ "$MUTED" -gt 0 ]; then
    echo "volume|0" > /tmp/qs_osd
else
    VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | head -1)
    echo "volume|${VOL:-0}" > /tmp/qs_osd
fi

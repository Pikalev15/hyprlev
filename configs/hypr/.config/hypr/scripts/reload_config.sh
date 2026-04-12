# Built to reload configs in one toggle script

hyprctl reload

killall -SIGUSR2 waybar

swaync-client --reload-config

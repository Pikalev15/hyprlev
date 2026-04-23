#!/bin/bash

if pgrep -x rofi > /dev/null; then
    pkill -x rofi
else
    sleep 0.1
    rofi -show drun \
         -theme ~/.config/rofi/config.rasi \
         -show-icons &
fi

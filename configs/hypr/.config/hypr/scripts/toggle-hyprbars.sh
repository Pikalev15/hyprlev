#!/bin/bash

STATE="$HOME/.cache/hyprbars_state"

if [ -f "$STATE" ]; then
    # ON
    hyprctl keyword plugin:hyprbars:bar_height 15
    hyprctl keyword plugin:hyprbars:bar_padding 8
    hyprctl keyword plugin:hyprbars:bar_button_padding 4
    hyprctl keyword plugin:hyprbars:bar_text_size 8
    hyprctl keyword plugin:hyprbars:col.text rgb\(e8d5f0\)
    rm "$STATE"
else
    # OFF
    hyprctl keyword plugin:hyprbars:bar_height 0
    hyprctl keyword plugin:hyprbars:bar_padding 0
    hyprctl keyword plugin:hyprbars:bar_button_padding 0
    hyprctl keyword plugin:hyprbars:bar_text_size 0
    hyprctl keyword plugin:hyprbars:col.text rgba\(00000000\)
    touch "$STATE"
fi

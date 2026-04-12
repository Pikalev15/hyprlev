#!/bin/bash
if hyprpm list | grep -A1 "hyprbars" | grep "enabled: true"; then
    hyprpm disable hyprbars
else
    hyprpm enable hyprbars
fi
hyprctl reload

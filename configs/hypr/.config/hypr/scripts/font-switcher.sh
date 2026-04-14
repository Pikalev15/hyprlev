#!/bin/bash

font_name=$(yad --font)
gsettings set org.gnome.desktop.interface font-name "font_name"

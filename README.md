<h2 align="center">HYPRLEV</h2>

<h4 align="center">
  <a href="https://github.com/Pikalev15/hyprlev/blob/main/documentation.md">Check out the documentation!</a><br><br>

my first dotfiles!

dont worry about shit hardware, im running my entire hyprland in a chromebook of a 128 gig usb

finally set up my sh script!

shoutout to claude for troubleshooting

other waybars other than island were acquired from the waybar examples page!

# Installation

```shell
sh <(curl -s https://raw.githubusercontent.com/Pikalev15/hyprlev/main/install.sh )
```

# Features
- Full theme switcher intergration
- wallpaper switcher
- waybar switcher
- nwg-dock-hyprland
- snappy-switcher for ALT TAB
- full gtk theme switching

# Instructions
To run the quickshell config by ilyamiro, run
```shell
quickshell -p ~/.config/hypr/scripts/quickshell/Main.qml & disown
quickshell -p ~/.config/hypr/scripts/quickshell/TopBar.qml & disown
```

To run my quickshell config, run
```shell
quickshell -p ~/quickshell/bar
```
On default, ilyamiro's config is attached to autostart.conf. To switch to waybar or quickshell, for now you have to manually update the autostart.conf

# TODO
 - [ ] Set up Matugen
 - [ ] Set up hyprpicker
 - [ ] Tweak swaync
 - [ ] set up html on start
 - [ ] make proper windowrules
 - [ ] proper cliphist setup
 - [ ] finish proper quickshell

# Progress
- [x] Hyprland
- [x] Hyprlock
- [x] Rofi
- [x] Waybar
- [x] Swaync
- [x] Wlogout
- [x] nwg-dock-hyprland


Thanks to
- [saneaspect] (https://github.com/saneaspect) for yt videos to learn how to set up hyprland efficiently!
- [ilyamiro] (https://github.com/ilyamiro) current quickshell config!

# hyprlev
![Hits](https://hits.sh/github.com/Pikalev15/hyprlev.svg)

Levi's Hyprland dotfiles...

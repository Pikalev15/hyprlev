###### _<div align="right"><sub>// by levi · Pikalev15</sub></div>_
<h1 align="center">HYPRLEV</h1>

<a href="https://github.com/Pikalev15/hyprlev/stargazers"><img src="https://img.shields.io/github/stars/Pikalev15/hyprlev?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=C9CBFF&labelColor=302D41" alt="stars"></a>&nbsp;&nbsp;
<a href="https://github.com/Pikalev15/hyprlev/forks"><img src="https://img.shields.io/github/forks/Pikalev15/hyprlev?style=for-the-badge&logo=git&logoColor=f9e2af&label=Forks&labelColor=302D41&color=f9e2af" alt="forks"></a>&nbsp;&nbsp;
<a href="https://github.com/Pikalev15/hyprlev/issues"><img src="https://img.shields.io/github/issues/Pikalev15/hyprlev?style=for-the-badge&logo=github&logoColor=eba0ac&label=Issues&labelColor=302D41&color=eba0ac" alt="issues"></a>&nbsp;&nbsp;
<a href="https://github.com/Pikalev15/hyprlev/commits/main"><img src="https://img.shields.io/github/last-commit/Pikalev15/hyprlev?style=for-the-badge&logo=github&logoColor=white&label=Last%20Commit&labelColor=302D41&color=A6E3A1" alt="last commit"></a>&nbsp;&nbsp;
<a href="https://github.com/Pikalev15/hyprlev/blob/main/LICENSE"><img src="https://img.shields.io/github/license/Pikalev15/hyprlev?style=for-the-badge&logo=open-source-initiative&color=CBA6F7&logoColor=CBA6F7&labelColor=302D41" alt="license"></a>&nbsp;&nbsp;
<div align="center">
  <a href="https://aur.archlinux.org/packages/hyprlev-git">
    <img src="https://img.shields.io/aur/version/hyprlev-git?style=for-the-badge&logo=open-source-initiative&color=CBA6F7&logoColor=CBA6F7&labelColor=302D41" alt="AUR">
  </a>
</div>

<h4 align="center">
  <a href="https://github.com/Pikalev15/hyprlev/blob/main/documentation.md">Check out the documentation!</a><br><br>
</h4>

my first dotfiles!

dont worry about shit hardware, im running my entire hyprland in a chromebook of a 128 gig usb

finally set up my sh script!

shoutout to claude for troubleshooting

other waybars other than island were acquired from the waybar examples page!

# Installation

```shell
yay -S hyprlev-git # currently quite unstable
hyprlev-install

or 

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Pikalev15/hyprlev/main/install.sh)"
```
or build from source




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

# misc
![Hits](https://hits.sh/github.com/Pikalev15/hyprlev.svg)


#!/bin/bash
# GitHub.com/PiercingXX

PKGMGR="paru -S --noconfirm"

echo "Ensuring build dependencies are available..."
${PKGMGR} base-devel
${PKGMGR} git
${PKGMGR} cmake
${PKGMGR} meson
${PKGMGR} pkg-config

echo "Installing Awesome core components..."
${PKGMGR} awesome
${PKGMGR} picom
${PKGMGR} dunst

echo "Installing X11 utilities used by Awesome config..."
${PKGMGR} xorg-server
${PKGMGR} xorg-xrandr
${PKGMGR} xorg-xinput
${PKGMGR} xorg-xsetroot
${PKGMGR} xorg-xrdb
${PKGMGR} xorg-setxkbmap
${PKGMGR} xorg-xev
${PKGMGR} numlockx
${PKGMGR} xterm

echo "Installing launcher, wallpaper, and clipboard tools..."
${PKGMGR} rofi
${PKGMGR} feh
${PKGMGR} nitrogen
${PKGMGR} lxappearance
${PKGMGR} xclip
${PKGMGR} xdotool
${PKGMGR} arandr
${PKGMGR} libnotify

echo "Installing terminal, editor, and font tools..."
${PKGMGR} kitty
${PKGMGR} neovim
${PKGMGR} tmux
${PKGMGR} ttf-jetbrains-mono-nerd

echo "Installing audio and brightness controls..."
${PKGMGR} pipewire
${PKGMGR} pipewire-pulse
${PKGMGR} wireplumber
${PKGMGR} pavucontrol
${PKGMGR} pamixer
${PKGMGR} playerctl
${PKGMGR} easyeffects
${PKGMGR} brightnessctl
${PKGMGR} light

echo "Installing auth/session helpers..."
${PKGMGR} networkmanager
${PKGMGR} network-manager-applet
${PKGMGR} polkit-gnome
${PKGMGR} gnome-keyring

echo -e "\nAll Awesome packages installed successfully!"
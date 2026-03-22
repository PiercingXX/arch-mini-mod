#!/bin/bash
# GitHub.com/PiercingXX

PKGMGR="paru -S --noconfirm"

echo "Ensuring build dependencies are available..."
${PKGMGR} base-devel
${PKGMGR} git
${PKGMGR} cmake
${PKGMGR} meson
${PKGMGR} pkg-config

echo "Installing i3 core components..."
${PKGMGR} i3-wm
${PKGMGR} i3blocks
${PKGMGR} i3lock
${PKGMGR} i3status
${PKGMGR} picom

echo "Installing X11 utilities used by i3 config..."
${PKGMGR} xorg-server
${PKGMGR} xorg-xrandr
${PKGMGR} xorg-xinput
${PKGMGR} xorg-xsetroot
${PKGMGR} xorg-xrdb
${PKGMGR} xorg-setxkbmap
${PKGMGR} xorg-xev
${PKGMGR} numlockx
${PKGMGR} feh

echo "Installing launcher/menu and screenshot tools..."
${PKGMGR} fuzzel
${PKGMGR} nwg-drawer
${PKGMGR} hyprshot
${PKGMGR} wl-clipboard
${PKGMGR} cliphist
${PKGMGR} betterlockscreen
${PKGMGR} hyprlock

echo "Installing audio and brightness controls..."
${PKGMGR} pipewire
${PKGMGR} pipewire-pulse
${PKGMGR} wireplumber
${PKGMGR} pavucontrol
${PKGMGR} pamixer
${PKGMGR} playerctl
${PKGMGR} easyeffects
${PKGMGR} light

echo "Installing auth/session helpers..."
${PKGMGR} polkit-gnome
${PKGMGR} gnome-keyring

echo "Installing terminal and file tools..."
${PKGMGR} kitty
${PKGMGR} tmux
${PKGMGR} nautilus
${PKGMGR} nautilus-renamer
${PKGMGR} nautilus-open-any-terminal
${PKGMGR} code-nautilus-git

echo "Installing system utilities used by blocks/scripts..."
${PKGMGR} networkmanager
${PKGMGR} network-manager-applet
${PKGMGR} acpi
${PKGMGR} upower

echo -e "\nAll i3 packages installed successfully!"
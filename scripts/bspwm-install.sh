#!/bin/bash
# GitHub.com/PiercingXX

PKGMGR="paru -S --noconfirm"

echo "Ensuring build dependencies are available..."
${PKGMGR} base-devel
${PKGMGR} git
${PKGMGR} cmake
${PKGMGR} meson
${PKGMGR} pkg-config

echo "Installing bspwm core components..."
${PKGMGR} bspwm
${PKGMGR} sxhkd
${PKGMGR} polybar
${PKGMGR} picom

echo "Installing X11 utilities used by bspwm config..."
${PKGMGR} xorg-server
${PKGMGR} xorg-xrandr
${PKGMGR} xorg-xsetroot
${PKGMGR} xorg-setxkbmap
${PKGMGR} xorg-xrdb
${PKGMGR} xorg-xev
${PKGMGR} xorg-xinput

echo "Installing launcher/background/screenshot tools..."
${PKGMGR} fuzzel
${PKGMGR} hsetroot
${PKGMGR} flameshot
${PKGMGR} sxiv
${PKGMGR} zathura

echo "Installing terminal, drag/drop and input tools..."
${PKGMGR} kitty
${PKGMGR} dragon-drag-and-drop
${PKGMGR} fcitx

echo "Installing network and auth helpers..."
${PKGMGR} networkmanager
${PKGMGR} network-manager-applet
${PKGMGR} polkit-gnome
${PKGMGR} gnome-keyring

echo "Installing optional swallow helpers..."
${PKGMGR} xdo
${PKGMGR} bspwm-swallow-git || echo "Warning: Optional package bspwm-swallow-git failed to install"

echo -e "\nAll bspwm packages installed successfully!"
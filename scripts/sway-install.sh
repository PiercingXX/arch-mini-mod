#!/bin/bash
# GitHub.com/PiercingXX

PKGMGR="paru -S --noconfirm"

echo "Ensuring build dependencies are available..."
${PKGMGR} base-devel
${PKGMGR} git
${PKGMGR} cmake
${PKGMGR} meson
${PKGMGR} pkg-config

echo "Installing Sway core components..."
${PKGMGR} sway
${PKGMGR} swaybg
${PKGMGR} swayidle
${PKGMGR} swaylock-effects
${PKGMGR} xdg-desktop-portal
${PKGMGR} xdg-desktop-portal-wlr

echo "Installing Wayland bar/launcher stack..."
${PKGMGR} waybar
${PKGMGR} nwg-drawer
${PKGMGR} fuzzel
${PKGMGR} wlogout
${PKGMGR} swaync
${PKGMGR} libnotify
${PKGMGR} notification-daemon

echo "Installing clipboard and screenshot tools..."
${PKGMGR} wl-clipboard
${PKGMGR} cliphist
${PKGMGR} hyprshot
${PKGMGR} brightnessctl
${PKGMGR} light

echo "Installing auth/session helpers..."
${PKGMGR} polkit-gnome
${PKGMGR} plasma-workspace
${PKGMGR} gnome-keyring

echo "Installing terminal and file tools..."
${PKGMGR} kitty
${PKGMGR} tmux
${PKGMGR} nautilus
${PKGMGR} nautilus-renamer
${PKGMGR} nautilus-open-any-terminal
${PKGMGR} code-nautilus-git

echo "Installing audio stack..."
${PKGMGR} pipewire
${PKGMGR} pipewire-pulse
${PKGMGR} wireplumber
${PKGMGR} pavucontrol
${PKGMGR} pamixer
${PKGMGR} playerctl
${PKGMGR} easyeffects

echo "Installing network and bluetooth utilities..."
${PKGMGR} networkmanager
${PKGMGR} network-manager-applet
${PKGMGR} bluez
${PKGMGR} bluez-utils
${PKGMGR} bluetuith

echo "Installing customization utilities..."
${PKGMGR} nwg-look
${PKGMGR} dconf
${PKGMGR} nwg-displays

echo -e "\nAll Sway packages installed successfully!"
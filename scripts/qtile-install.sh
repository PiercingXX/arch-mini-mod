#!/bin/bash
# GitHub.com/PiercingXX

PKGMGR="paru -S --noconfirm"

echo "Ensuring build dependencies are available..."
${PKGMGR} base-devel
${PKGMGR} git
${PKGMGR} cmake
${PKGMGR} meson
${PKGMGR} pkg-config

echo "Installing Qtile core components..."
${PKGMGR} qtile
${PKGMGR} python-psutil
${PKGMGR} picom
${PKGMGR} dmenu

echo "Installing X11 utilities used by Qtile config..."
${PKGMGR} xorg-server
${PKGMGR} xorg-xinit
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

echo "Installing system utilities used by widgets/scripts..."
${PKGMGR} networkmanager
${PKGMGR} network-manager-applet
${PKGMGR} acpi
${PKGMGR} upower

echo "Creating Qtile session launchers..."
sudo tee /usr/local/bin/start-qtile >/dev/null <<'EOF'
#!/bin/sh
if ! command -v qtile >/dev/null 2>&1; then
	echo "qtile is not installed. Run the qtile installer first." >&2
	exit 127
fi

if command -v startx >/dev/null 2>&1; then
	exec dbus-run-session startx /usr/bin/qtile start -- "$@"
fi

exec dbus-run-session qtile start "$@"
EOF
sudo chmod +x /usr/local/bin/start-qtile

sudo tee /usr/local/bin/qtile-session >/dev/null <<'EOF'
#!/bin/sh
exec /usr/local/bin/start-qtile "$@"
EOF
sudo chmod +x /usr/local/bin/qtile-session

echo -e "\nAll Qtile packages installed successfully!"
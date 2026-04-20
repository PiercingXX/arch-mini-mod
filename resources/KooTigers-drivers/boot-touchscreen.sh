#!/bin/bash
# GitHub.com/PiercingXX

set -uo pipefail

# Script to install and enable KooTigers drivers service

# Base path of this repo (resolve script dir so it works from anywhere)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SERVICE_SRC="$REPO_ROOT/resources/KooTigers-drivers/kootigers-drivers.service"
SCRIPT_SRC="$REPO_ROOT/resources/KooTigers-drivers/kootigers-drivers.sh"

sudo cp "$SERVICE_SRC" /etc/systemd/system/
sudo cp "$SCRIPT_SRC" /usr/local/bin/
sudo chmod +x /usr/local/bin/kootigers-drivers.sh
sudo systemctl daemon-reload
sudo systemctl enable --now kootigers-drivers.service

# Install iio-sensor-proxy depending on distro
if command -v pacman >/dev/null 2>&1; then
    echo "Detected Arch-based system; installing iio-sensor-proxy via pacman..."
    sudo pacman -S --needed --noconfirm iio-sensor-proxy
elif command -v apt-get >/dev/null 2>&1; then
    echo "Detected Debian/Ubuntu-based system; installing iio-sensor-proxy via apt..."
    sudo apt-get update
    sudo apt-get install -y iio-sensor-proxy
else
    echo "Warning: could not detect supported package manager (pacman/apt)."
    echo "Please install 'iio-sensor-proxy' manually."
fi

# Enable and start iio-sensor-proxy if it exists
if systemctl list-unit-files | grep -q '^iio-sensor-proxy\.service'; then
    sudo systemctl enable --now iio-sensor-proxy.service
    echo
    echo "You can now test sensors with:"
    echo "  monitor-sensor    # from package 'iio-sensor-proxy'"
else
    echo "iio-sensor-proxy.service not found; check installation."
fi
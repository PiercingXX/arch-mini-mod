#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Pop Shell Installation Script${NC}"
echo "================================"

# Check if running GNOME
if ! command -v gnome-shell &> /dev/null; then
    echo -e "${RED}Error: GNOME Shell not found. This extension requires GNOME.${NC}"
    exit 1
fi

GNOME_VERSION=$(gnome-shell --version | cut -d' ' -f3 | cut -d'.' -f1)
echo -e "${GREEN}✓${NC} GNOME Shell version: $(gnome-shell --version)"

# Install dependencies
echo ""
echo "Installing dependencies..."
if ! dpkg -l | grep -q node-typescript; then
    sudo apt update
    sudo apt install -y node-typescript git make
    echo -e "${GREEN}✓${NC} Dependencies installed"
else
    echo -e "${GREEN}✓${NC} Dependencies already installed"
fi

# Clean up any previous installation attempts
if [ -d "/tmp/pop-shell" ]; then
    echo "Cleaning up previous installation..."
    rm -rf /tmp/pop-shell
fi

# Clone repository
echo ""
echo "Cloning Pop Shell repository..."
cd /tmp
git clone https://github.com/pop-os/shell.git pop-shell
echo -e "${GREEN}✓${NC} Repository cloned"

# Build and install
echo ""
echo "Building and installing Pop Shell..."
cd /tmp/pop-shell
make local-install

# Check installation
if [ -d "$HOME/.local/share/gnome-shell/extensions/pop-shell@system76.com" ]; then
    echo -e "${GREEN}✓${NC} Pop Shell installed successfully!"
else
    echo -e "${RED}✗${NC} Installation may have failed. Check the output above."
    exit 1
fi

# Instructions
echo ""
echo -e "${YELLOW}════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Installation complete!${NC}"
echo ""
echo "To activate Pop Shell:"
echo "  1. Log out and log back in"
echo "  2. Then run: gnome-extensions enable pop-shell@system76.com"
echo ""
echo "Or restart GNOME Shell now:"
echo "  killall -3 gnome-shell"
echo ""
echo -e "${YELLOW}════════════════════════════════════════════════${NC}"

# Clean up
rm -rf /tmp/pop-shell

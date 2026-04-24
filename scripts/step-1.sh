#!/bin/bash
# GitHub.com/PiercingXX

set -uo pipefail

FAILED_COMMANDS=()

record_failure() {
    local rc=$?
    local line_no="$1"
    local cmd="$BASH_COMMAND"

    # Avoid trap noise from trap internals.
    if [[ "$cmd" == *record_failure* ]]; then
        return 0
    fi

    FAILED_COMMANDS+=("line ${line_no}: ${cmd} (exit ${rc})")
    return 0
}

print_failure_summary() {
    if [[ ${#FAILED_COMMANDS[@]} -eq 0 ]]; then
        echo -e "${GREEN}Installer finished with no command failures.${NC}"
        return 0
    fi

    echo
    echo "# Installer completed with failures (${#FAILED_COMMANDS[@]}):"
    local failure
    for failure in "${FAILED_COMMANDS[@]}"; do
        echo "- ${failure}"
    done
}

trap 'record_failure ${LINENO}' ERR

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m'

username=$(id -u -n 1000)
builddir=$(pwd)

install_bashrc_support() {
    return 0
}

install_optional_arch_packages() {
    local pkg

    for pkg in "$@"; do
        if pacman -Si "$pkg" >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm "$pkg"
        else
            printf '# Optional package not found in repos, skipping: %s\n' "$pkg"
        fi
    done
}

configure_pipewire_session() {
    sudo mkdir -p /etc/xdg/autostart

    if [ -f /usr/share/applications/pipewire.desktop ]; then
        sudo ln -snf /usr/share/applications/pipewire.desktop /etc/xdg/autostart/pipewire.desktop
    fi

    if [ -f /usr/share/applications/pipewire-pulse.desktop ]; then
        sudo ln -snf /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/pipewire-pulse.desktop
    fi

    if [ -f /usr/share/applications/wireplumber.desktop ]; then
        sudo ln -snf /usr/share/applications/wireplumber.desktop /etc/xdg/autostart/wireplumber.desktop
    fi
}

ensure_tty_boot_without_gdm() {
    # Keep boot flow in TTY and prevent display manager auto-start.
    if systemctl list-unit-files | grep -q '^gdm\.service'; then
        sudo systemctl disable --now gdm.service || true
        sudo systemctl mask gdm.service || true
    fi

    sudo systemctl set-default multi-user.target
}


# Create Directories if needed
    echo -e "${YELLOW}Creating Necessary Directories...${NC}"
        # font directory
            if [ ! -d "$HOME/.fonts" ]; then
                mkdir -p "$HOME/.fonts"
            fi
            chown -R "$username":"$username" "$HOME"/.fonts
        # icons directory
            if [ ! -d "$HOME/.icons" ]; then
                mkdir -p /home/"$username"/.icons
            fi
            chown -R "$username":"$username" /home/"$username"/.icons
        # Background and Profile Image Directories
            if [ ! -d "$HOME/Pictures/backgrounds" ]; then
                mkdir -p /home/"$username"/Pictures/backgrounds
            fi
            chown -R "$username":"$username" /home/"$username"/Pictures/backgrounds
            if [ ! -d "$HOME/Pictures/profile-image" ]; then
                mkdir -p /home/"$username"/Pictures/profile-image
            fi
            chown -R "$username":"$username" /home/"$username"/Pictures/profile-image

# System Update
    sudo pacman -Syu --noconfirm

# Install dependencies
    echo "# Installing dependencies..."
    sudo pacman -S trash-cli --noconfirm
    sudo pacman -S fastfetch --noconfirm
    sudo pacman -S tree --noconfirm
    sudo pacman -S zoxide --noconfirm
    sudo pacman -S bash-completion --noconfirm
    sudo pacman -S starship --noconfirm
    sudo pacman -S eza --noconfirm
    sudo pacman -S bat --noconfirm
    sudo pacman -S --needed --overwrite '/usr/share/fzf/*' fzf --noconfirm
    sudo pacman -S trash-cli --noconfirm
    sudo pacman -S chafa --noconfirm
    sudo pacman -S w3m --noconfirm
    sudo pacman -S reflector --noconfirm
    sudo pacman -S zip unzip gzip tar make wget tar fontconfig --noconfirm
    sudo pacman -S --needed --noconfirm linux-firmware
    sudo pacman -S bluez bluez-utils --noconfirm
    sudo pacman -S iw --noconfirm
    sudo pacman -S tmux --noconfirm
    sudo pacman -S sshpass --noconfirm
    sudo pacman -S rsync --noconfirm
    sudo pacman -S htop --noconfirm
    sudo pacman -S gnome-shell --noconfirm
    sudo pacman -S --needed --noconfirm webkit2gtk-4.1
    install_optional_arch_packages linux-firmware-brcm43752 linux-firmware-broadcom linux-firmware-realtek

# Add Paru, Flatpak, & Dependencies if needed
    echo -e "${YELLOW}Installing Paru, Flatpak, & Dependencies...${NC}"
        # Install Paru
        # Ensure build prerequisites are present and avoid cargo provider prompt under --noconfirm.
        sudo pacman -S --needed --noconfirm git base-devel rust cargo
        git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm && cd ..
        # Packages that require AUR helper
        paru -S nvtop-git --noconfirm
        paru -S lnav --noconfirm
        # Add Flatpak
        echo "# Installing Flatpak..."
        sudo pacman -S flatpak --noconfirm
        sudo flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        sudo flatpak remote-add --system --if-not-exists flathub-beta https://flathub.org/beta-repo/flathub-beta.flatpakrepo


# Installing more Depends
    echo "# Installing more dependencies..."
    paru -S multitail jump-bin --noconfirm
    paru -S bluetuith --noconfirm
    paru -S dconf --noconfirm
    paru -S cpio cmake meson --noconfirm
    paru -S fwupd --noconfirm
    paru -S w3m --noconfirm
    paru -S kitty --noconfirm
    paru -S python --noconfirm
    paru -S wmctrl xdotool libinput-gestures --noconfirm
    paru -S npm --noconfirm
    paru -S nautilus-open-any-terminal --noconfirm
    paru -S proton-vpn-gtk-app --noconfirm
    paru -S nvtop-git --noconfirm
    paru -S lnav --noconfirm
    sudo flatpak install --system flathub net.waterfox.waterfox -y
    sudo flatpak install --system flathub md.obsidian.Obsidian -y
    sudo flatpak install --system flathub org.libreoffice.LibreOffice -y
    sudo flatpak install --system flathub com.mattjakeman.ExtensionManager -y
    sudo flatpak install --system flathub org.qbittorrent.qBittorrent -y
    sudo flatpak install --system flathub io.missioncenter.MissionCenter -y
    sudo flatpak install --system flathub io.github.shiftey.Desktop -y #Github Desktop
    sudo flatpak install --system --noninteractive flathub io.github.realmazharhussain.GdmSettings -y


#Hyprland and Utilities
    paru -S --noconfirm hyprland-meta-git
    if pacman -Q hyprpaper-git >/dev/null 2>&1; then
        echo "# hyprpaper-git already present; skipping hyprpaper to avoid conflicts"
    else
        paru -S --needed --noconfirm hyprpaper
    fi
    if pacman -Q hypridle-git >/dev/null 2>&1; then
        echo "# hypridle-git already present; skipping hypridle to avoid conflicts"
    else
        paru -S --needed --noconfirm hypridle
    fi
    paru -S --noconfirm polkit-gnome
    paru -S --noconfirm wl-clipboard
    paru -S --noconfirm libdbusmenu-gtk3
    paru -S --noconfirm waybar
    paru -S --noconfirm nwg-drawer
    paru -S --noconfirm fuzzel
    paru -S --noconfirm wlogout
    paru -S --noconfirm libnotify
    paru -S --noconfirm notification-daemon
    paru -S --noconfirm swaync
    paru -S --noconfirm hyprshot
    paru -S --noconfirm wl-gammarelay
    paru -S --noconfirm brightnessctl
    paru -S --noconfirm light
    paru -S --noconfirm cliphist
    paru -S --noconfirm pamixer
    paru -S --noconfirm cava
    sudo pacman -S pipewire wireplumber pipewire-pulse pipewire-alsa --noconfirm
    sudo pacman -S gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav --noconfirm
    paru -S --noconfirm wireplumber
    paru -S --noconfirm playerctl
    paru -S --noconfirm pavucontrol
    paru -S --noconfirm networkmanager
    paru -S --noconfirm network-manager-applet
    paru -S --noconfirm nwg-look
    paru -S --noconfirm nwg-displays
    configure_pipewire_session

# Nvim & Depends
    paru -Rs neovim --noconfirm
    paru -S neovim-nightly-bin --noconfirm
    sudo pacman -S nodejs npm --noconfirm
    sudo pacman -S ripgrep --noconfirm
    paru -S lua51 --noconfirm
    paru -S python --noconfirm
    paru -S python-pip --noconfirm
    paru -S python-pynvim --noconfirm
    python3 -m pip install --user --upgrade pynvim
    sudo pacman -S chafa --noconfirm
    sudo pacman -S ripgrep --noconfirm

# VScode
    paru -S visual-studio-code-bin --noconfirm
    paru -S code-nautilus-git --noconfirm

# Firewall
    paru -S ufw --noconfirm
    sudo ufw allow OpenSSH

# Install bash stuff
    install_bashrc_support

# Yazi
    paru -S yazi-nightly-bin --noconfirm
    paru -S ffmpeg --noconfirm
    paru -S 7zip --noconfirm
    paru -S jq --noconfirm
    paru -S poppler --noconfirm
    paru -S fd --noconfirm
    paru -S ripgrep --noconfirm
    paru -S zoxide --noconfirm
    paru -S resvg --noconfirm
    paru -S imagemagick --noconfirm
    ya pkg add dedukun/bookmarks
    ya pkg add yazi-rs/plugins:mount
    ya pkg add dedukun/relative-motions
    ya pkg add yazi-rs/plugins:chmod
    ya pkg add yazi-rs/plugins:smart-enter
    ya pkg add AnirudhG07/rich-preview
    ya pkg add grappas/wl-clipboard
    ya pkg add Rolv-Apneseth/starship
    ya pkg add yazi-rs/plugins:full-border
    ya pkg add uhs-robert/recycle-bin
    ya pkg add yazi-rs/plugins:diff

# Apps to uninstall
    sudo pacman -Rs gnome-console --noconfirm
    sudo pacman -Rs firefox --noconfirm
    sudo pacman -Rs epiphany --noconfirm
    sudo pacman -Rs gnome-terminal --noconfirm
    sudo pacman -Rs gnome-software --noconfirm
    sudo pacman -Rs software-center --noconfirm
    sudo pacman -Rs dolphin --noconfirm
    sudo pacman -Rs gnome-maps --noconfirm
    sudo pacman -Rs gnome-photos --noconfirm
    sudo pacman -Rs gnome-calendar --noconfirm
    sudo pacman -Rs gnome-contacts --noconfirm
    sudo pacman -Rs gnome-music --noconfirm
    sudo pacman -Rs gnome-text-editor --noconfirm
    sudo pacman -Rs gnome-weather --noconfirm

# Synology
    paru -S synology-drive --noconfirm
    #Synology Drive doesnt support wayland so run this...
    QT_QPA_PLATFORM=xcb

# Tailscale
    paru -S tailscale --noconfirm
    curl -fsSL https://tailscale.com/install.sh | sh
    wait

# Theme stuffs
    paru -S papirus-icon-theme-git --noconfirm

# Install fonts
    echo "Installing Fonts"
    cd "$builddir" || exit
    sudo pacman -S ttf-firacode-nerd --noconfirm
    paru -S ttf-nerd-fonts-symbols --noconfirm
    paru -S noto-fonts-emoji-colrv1 --noconfirm
    sudo pacman -S ttf-jetbrains-mono-nerd --noconfirm
    paru -S awesome-terminal-fonts-patched --noconfirm
    paru -S ttf-ms-fonts --noconfirm
    paru -S terminus-font-ttf --noconfirm
    paru -S wtype-git --noconfirm
    paru -S --needed win2xcur --noconfirm
    # Reload Font
    fc-cache -vf
    wait

# OpenSSH
    echo "# Enabling OpenSSH Service..."
    sudo pacman -S openssh --noconfirm
    sudo systemctl enable sshd
    sudo systemctl start sshd

# Apply Piercing Rice
    echo -e "${YELLOW}Applying PiercingXX Gnome Customizations...${NC}"
    rm -rf piercing-dots
    git clone --depth 1 https://github.com/Piercingxx/piercing-dots.git
    cd piercing-dots || exit
    chmod u+x install.sh
    ./install.sh
    cd "$builddir" || exit
    rm -rf piercing-dots

# System Control Services
    echo "# Enabling Bluetooth and Printer services..."
    # Enable Bluetooth
        sudo systemctl start bluetooth
        sudo systemctl enable bluetooth
    # Enable Printer 
        sudo pacman -S cups gutenprint cups-pdf gtk3-print-backends nmap net-tools cmake meson cpio --noconfirm
        sudo systemctl enable cups.service
        sudo systemctl start cups
    # Printer Drivers
        paru -S cnijfilter2-mg3600 --noconfirm #Canon mg3600 driver
        #paru -S cndrvcups-lb --noconfirm # Canon D530 driver
    # Add dialout to edit ZMK and VIA Keyboards
        sudo usermod -aG uucp $USER

# Keep system on TTY by default (no GDM)
    ensure_tty_boot_without_gdm

# Install Ulauncher directly from AUR checkout.
    rm -rf /tmp/ulauncher
    git clone --depth 1 https://aur.archlinux.org/ulauncher.git /tmp/ulauncher
    (
        cd /tmp/ulauncher || exit
        # Arch now ships webkit2gtk as webkit2gtk-4.1; patch old AUR dep name.
        sed -i "s/'webkit2gtk'/'webkit2gtk-4.1'/" PKGBUILD
        makepkg -is --needed --noconfirm
    )

print_failure_summary
exit 0

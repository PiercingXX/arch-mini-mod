#!/bin/bash
# GitHub.com/PiercingXX

username=$(id -u -n 1000)
builddir=$(pwd)


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
            if [ ! -d "$HOME/$username/Pictures/backgrounds" ]; then
                mkdir -p /home/"$username"/Pictures/backgrounds
            fi
            chown -R "$username":"$username" /home/"$username"/Pictures/backgrounds
            if [ ! -d "$HOME/$username/Pictures/profile-image" ]; then
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
    sudo pacman -S fzf --noconfirm
    sudo pacman -S trash-cli --noconfirm
    sudo pacman -S chafa --noconfirm
    sudo pacman -S w3m --noconfirm
    sudo pacman -S reflector --noconfirm
    sudo pacman -S zip unzip gzip tar make wget tar fontconfig --noconfirm
    sudo pacman -Syu linux-firmware linux-firmware-brcm43752 linux-firmware-broadcom linux-firmware-realtek --noconfirm
    sudo pacman -S bluez bluez-utils --noconfirm
    sudo pacman -S iw --noconfirm
    sudo pacman -S tmux --noconfirm
    sudo pacman -S sshpass --noconfirm
    sudo pacman -S htop --noconfirm

# Add Paru
    echo -e "${YELLOW}Installing Paru, Flatpak, & Dependencies...${NC}"
        # Clone and install Paru
        echo "# Cloning and installing Paru..."
        git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si --noconfirm && cd ..

# Installing more Depends
    echo "# Installing more dependencies..."
    paru -S multitail jump-bin --noconfirm
    paru -S bluetuith --noconfirm
    paru -S dconf --noconfirm
    paru -S cpio cmake meson --nocofirm
    paru -S fwupd --noconfirm
    paru -S w3m --noconfirm
    paru -S kitty --noconfirm
    paru -S python --noconfirm
    paru -S wmctrl xdotool libinput-gestures --noconfirm
    paru -S npm --noconfirm
    paru -S nautilus-open-any-terminal --noconfirm
    paru -S nautilus-renamer --noconfirm
    paru -S ulauncher --noconfirm
    paru -S proton-vpn-gtk-app --noconfirm
    paru -S nvtop-git --noconfirm
    paru -S lnav --noconfirm
    flatpak install flathub net.waterfox.waterfox -y
    flatpak install flathub md.obsidian.Obsidian -y
    flatpak install flathub org.libreoffice.LibreOffice -y
    flatpak install flathub com.mattjakeman.ExtensionManager -y
    flatpak install flathub org.qbittorrent.qBittorrent -y
    flatpak install flathub io.missioncenter.MissionCenter -y
    flatpak install flathub io.github.shiftey.Desktop -y #Github Desktop
    flatpak install --noninteractive flathub io.github.realmazharhussain.GdmSettings -y


#Hyprland and Utilities
    paru -S --noconfirm hyprland-meta-git
    paru -S --noconfirm hyprpaper
    paru -S --noconfirm hypridle
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
    paru -S --noconfirm wireplumber
    paru -S --noconfirm playerctl
    paru -S --noconfirm pavucontrol
    paru -S --noconfirm networkmanager
    paru -S --noconfirm network-manager-applet
    paru -S --noconfirm nwg-look
    paru -S --noconfirm nwg-displays

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
    paru -S fzf --noconfirm
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
    paru -S xcursor-simp1e-gruvbox-light --noconfirm
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
        systemctl enable bluetooth
    # Enable Printer 
        sudo pacman -S cups gutenprint cups-pdf gtk3-print-backends nmap net-tools cmake meson cpio --noconfirm
        sudo systemctl enable cups.service
        sudo systemctl start cups
    # Printer Drivers
        paru -S cnijfilter2-mg3600 --noconfirm #Canon mg3600 driver
        #paru -S cndrvcups-lb --noconfirm # Canon D530 driver
    # Add dialout to edit ZMK and VIA Keyboards
        sudo usermod -aG uucp $USER
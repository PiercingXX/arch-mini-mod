#!/bin/bash
# GitHub.com/PiercingXX

# Define colors for whiptail

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "This script should not be executed as root! Exiting......."
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to cache sudo credentials
cache_sudo_credentials() {
    echo "Caching sudo credentials for script execution..."
    sudo -v
    # Keep sudo credentials fresh for the duration of the script
    (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &)
}

# Checks for active network connection
if [[ -n "$(command -v nmcli)" && "$(nmcli -t -f STATE g)" != connected ]]; then
    awk '{print}' <<<"Network connectivity is required to continue."
    exit
fi

# Check for active network connection
    if command_exists nmcli; then
        state=$(nmcli -t -f STATE g)
        if [[ "$state" != connected ]]; then
            echo "Network connectivity is required to continue."
            exit 1
        fi
    else
        # Fallback: ensure at least one interface has an IPv4 address
        if ! ip -4 addr show | grep -q "inet "; then
            echo "Network connectivity is required to continue."
            exit 1
        fi
    fi
        # Additional ping test to confirm internet reachability
        if ! ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
            echo "Network connectivity is required to continue."
            exit 1
        fi



# Ensure gum is installed, auto-install if missing
if ! command -v gum &> /dev/null; then
    echo -e "${YELLOW}gum is not installed. Attempting to install...${NC}"
    if command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm gum
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y gum
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y gum
    elif command -v brew &> /dev/null; then
        brew install gum
    else
        echo "Could not determine package manager. Please install 'gum' manually."
        exit 1
    fi
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# Cache sudo credentials
cache_sudo_credentials


# Function to display a message box using gum
function msg_box() {
    gum style --border double --margin "1 2" --padding "1 2" --foreground 212 "$1" | gum pager
}

# Function to display menu using gum
function menu() {
    gum choose \
        "Install Arch Mini Mod" \
        "Window Managers" \
        "Install Nvidia Drivers" \
        "Apply KooTigers Touchscreen Driver" \
        "Apply NuVision 8in Tablet Fixes" \
        "Apply Microsoft Surface Kernel" \
        "Reboot System" \
        "Exit"
}

function window_manager_menu() {
    gum choose \
        "Install Hyprland" \
        "Install Sway" \
        "Install i3" \
        "Install bspwm" \
        "Back"
}

run_wm_install_script() {
    local label="$1"
    local script_name="$2"

    echo -e "${YELLOW}Installing ${label} & Dependencies...${NC}"
    cd scripts || exit
    chmod u+x "$script_name"
    ./$script_name
    cd "$builddir" || exit
    echo -e "${GREEN}${label} Installed successfully!${NC}"
}

install_selected_window_managers() {
    local wm_choices
    local wm_choice

    wm_choices=$(window_manager_menu) || wm_choices=""
    [ -n "$wm_choices" ] || return 0

    if [ "$wm_choices" = "Back" ]; then
        return 0
    fi

    wm_choice="$wm_choices"
    case $wm_choice in
        "Install Hyprland")
            run_wm_install_script "Hyprland" "hyprland-install.sh"
            ;;
        "Install Sway")
            run_wm_install_script "Sway" "sway-install.sh"
            ;;
        "Install i3")
            run_wm_install_script "i3" "i3-install.sh"
            ;;
        "Install bspwm")
            run_wm_install_script "bspwm" "bspwm-install.sh"
            ;;
    esac
}

prompt_install_window_managers_after_install() {
    if gum confirm "Install window managers before reboot?"; then
        install_selected_window_managers
    fi
}
# Main menu loop
while true; do
    clear
    echo -e "${BLUE}PiercingXX's Arch Mod Script${NC}"
    echo -e "${GREEN}Welcome ${username}${NC}\n"
    choice=$(menu)
    case $choice in
        "Install Arch Mini Mod")
            # Turn off sleep/suspend to avoid interruptions
                echo -e "${YELLOW}Installing Essentials...${NC}"
                cd scripts || exit
                chmod u+x step-1.sh
                ./step-1.sh
                wait
                cd "$builddir" || exit
                echo -e "${GREEN}Essentials Installed successfully!${NC}"
                echo -e "${YELLOW}Applying PiercingXX Gnome Customizations...${NC}"
                rm -rf piercing-dots
                git clone --depth 1 https://github.com/Piercingxx/piercing-dots.git
                cd piercing-dots || exit
                chmod u+x install.sh
                ./install.sh
                cd "$builddir" || exit
                wait
                sudo systemctl start bluetooth
                systemctl enable bluetooth
                cd piercing-dots/scripts || exit
                ./gnome-customizations.sh
                wait
                cd "$builddir" || exit
            # Bash support
                cp -f piercing-dots/resources/bash/.bashrc /home/"$username"/.bashrc
                source "$HOME/.bashrc"
                rm -rf piercing-dots
            # Install bash stuff
                install_bashrc_support
            echo -e "${GREEN}PiercingXX Gnome Customizations Applied successfully!${NC}"
            # Install Pop Shell
                chmod u+x scripts/install-pop-shell.sh
                ./scripts/install-pop-shell.sh
                wait
                cd "$builddir" || exit
            # Install Printers
                chmod u+x scripts/install-printers.sh
                ./scripts/install-printers.sh
                wait
                cd "$builddir" || exit
            prompt_install_window_managers_after_install
            msg_box "System will reboot now."
            sudo reboot
            ;;
        "Window Managers")
            install_selected_window_managers
            ;;
        "Install Nvidia Drivers")
            echo -e "${YELLOW}Installing Nvidia Drivers...${NC}"
            cd scripts || exit
            chmod +x ./nvidia.sh
            sudo ./nvidia.sh
            cd "$builddir" || exit
            ;;
        "Apply KooTigers Touchscreen Driver")
            echo -e "${YELLOW}Applying KooTigers Touchscreen Driver...${NC}"
            cd resources/KooTigers-drivers/ || exit
            chmod +x ./kootigers-drivers.sh
            sudo ./kootigers-drivers.sh
            cd "$builddir" || exit
            echo -e "${GREEN}KooTigers Touchscreen Driver Applied Successfully! Please Reboot!${NC}"
            ;;
        "Apply NuVision 8in Tablet Fixes")
            echo -e "${YELLOW}Applying NuVision 8in Tablet Fixes...${NC}"
            cd resources/NuVision-8in-tablet/ || exit
            chmod +x ./nuvision-tablet-drivers.sh
            sudo ./nuvision-tablet-drivers.sh
            cd "$builddir" || exit
            echo -e "${GREEN}NuVision 8in Tablet Fixes Applied Successfully! Please Reboot!${NC}"
            ;;
        "Apply Microsoft Surface Kernel")
            echo -e "${YELLOW}Microsoft Surface Kernel...${NC}"
            cd scripts || exit
            chmod +x ./surface-kernel.sh
            sudo ./surface-kernel.sh
            cd "$builddir" || exit
            echo -e "${GREEN}Microsoft Kernal Installed. Manually create a Boot Loader Entry then reboot!${NC}"
            ;;
        "Reboot System")
            echo -e "${YELLOW}Rebooting system in 3 seconds...${NC}"
            sleep 1
            reboot
            ;;
        "Exit")
            clear
            echo -e "${BLUE}Thank You Handsome!${NC}"
            exit 0
            ;;
    esac
    # Prompt to continue
    gum confirm "Press [Enter] to continue..." || break
done


# Arch‑Mini‑Mod

A minimal Arch Linux installer focused on Hyprland.

Designed for a lightweight setup, ideal for Linux tablets, and touch devices, but also lightweight laptop setup.

GDM is disabled by default. You can enable it in tty. 

This is a dual setup. 
    - Gnome for touchscreen stuff (boot into Gnome)
    - An ultra minimal Hyprland setup without waybar (boot into hypr)
        I work mainly in tmux on the devices I use this on with a keyboard. 
        If you simply install waybar and reboot, the dots already support it. 


## 📦 Features

- Minimal install: only core packages, Gnome, and Hyprland
- Lightweight and fast, perfect for tablets or low-resource devices
- Optional Microsoft Surface kernel support
- Optional KooTigers Mini Pc support
- Optional NuVision 8" Tablet TM800W610L support
- Touch-friendly configuration
- Applies [Piercing‑Dots](https://github.com/PiercingXX/piercing-dots) minimal dotfiles



## 🚀 Quick Start

```bash
git clone https://github.com/PiercingXX/arch-mini-mod
cd arch-mini-mod
chmod -R u+x scripts/
./arch-mod.sh
```



## 🛠️ Usage

Run `./arch-mod.sh` and follow the prompts.  
Options include minimal system install, Surface kernel, Hyprland, and reboot.



## Linux on KooTigers Mini Pc
Almost everything worked out of the box. Touch Screen and screen rotation both didnt work.
Touch screen now works perfectly, screen rotation is sketchy. I dont use it so I turned it off in Gnome, and not a concern in Hyprland.

**How to fix:**
Just run the script or from inside ./arch-mini-mod.sh hit "Apply KooTigers Touchscreen Driver".
After just reboot and you're ready to go.

Check the [README](https://github.com/Piercingxx/arch-mini-mod/blob/main/resources/KooTigers-drivers/README.md) for more information.




## Linux on NuVision 8" Tablet TM800W610L
Wi-Fi and bluetooth drivers are not found in linux kernel by default. I ripped the wifi driver out of the windows install but the bluetooth driver was a royal pain. Had to rebuild it from binary...4 hours of my life gone.
    - Wi-Fi and Bluetooth both work perfectly now.

Audio is also non-functional out of the box.

Screen orientation is rotated 90° on Debian GNOME and Plasma, and does not auto-rotate on Arch until you install the Wi-Fi driver.

**How to fix:**

Just run the `nuvision-tablet-drivers.sh` script. This script is also included in the whiptail menu of the main `arch-mini-mod.sh` installer.

Check the [README](https://github.com/Piercingxx/arch-mini-mod/blob/main/resources/NuVision-8in-tablet/README.md) for more information.




## 🔧 Optional Scripts

| Script                | Purpose                                 |
|-----------------------|-----------------------------------------|
| `scripts/apps.sh`     | Installs core desktop applications      |
| `scripts/qtile-install.sh` | Installs Qtile and X11 dependencies |
| `scripts/install-printers.sh` | Configures Canon D530 or Omezizy label printers |
| `scripts/nvidia.sh`   | Installs proprietary NVIDIA drivers     |
| `kootigers-drivers.sh` | Copies drivers and applies patch          |
| `nuvision-tablet-drivers.sh` |Copies drivers and applies patch     |
| `scripts/Surface.sh`  | Installs Microsoft Surface kernel       |

---

## 📄 License

MIT © PiercingXX  
See the LICENSE file for details.

---

## 🤝 Contributing

Fork, branch, and PR welcome.  

---

## 📞 Support & Contact

    Email: Don’t

    Open an issue in the relevant repo instead. If it’s a rant make it entertaining.

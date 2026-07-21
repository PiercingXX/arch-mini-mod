# NuVision 8" Tablet Drivers & Scripts

Enable WiFi, Bluetooth, and audio support for NuVision 8" tablets on Arch Linux and similar distros.

---

## 📦 What This Does

- Provides scripts and drivers for WiFi, Bluetooth, and audio hardware
- Includes startup scripts and desktop entry for automatic WiFi initialization
- Contains firmware files for Broadcom WiFi/Bluetooth chips
- Designed for use with Arch Linux (may work with other distros with minor tweaks)

---

## 🚀 Quick Install

Run the main installer script as root:

```bash
sudo ./nuvision-tablet-drivers.sh
```

Or, copy the files manually:

```bash
# WiFi/Bluetooth firmware
sudo cp wifi-bluetooth-drivers/* /lib/firmware/

# Audio drivers (if present)
sudo cp audio-drivers/* /lib/firmware/

# WiFi startup script and desktop entry
sudo cp wifi-startup.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/wifi-startup.sh
sudo cp wifi-startup.desktop /etc/xdg/autostart/
```

---

## 🛠️ Usage

1. Make sure your system uses **systemd** and supports autostart desktop entries.
2. Run the installer as **root** (or use the manual steps above).
3. Reboot your system.
4. Test WiFi, Bluetooth, and audio functionality.
5. If WiFi does not start automatically, check the desktop entry and script permissions.

---

## 📶 WiFi Dropouts / Bluetooth Stutter Fix

If WiFi randomly disconnects or Bluetooth is unusable while WiFi is on
(applies to the BCM43430a0 / AP6212 chip, also found in the TMAX TM800W610L):

```bash
sudo ./fix-wifi-bt.sh
```

Then reboot. This does three things:

- **`roamoff=1`** (`/etc/modprobe.d/brcmfmac.conf`) — the 2017 43430a0 firmware's
  internal roaming engine crashes `brcmfmac` (look for `brcmf_bss_roaming_done`
  WARNs in `dmesg`) and drops the connection; this hands roaming to wpa_supplicant.
- **WiFi powersave off** (`/etc/NetworkManager/conf.d/wifi-powersave-off.conf`) —
  SDIO powersave on this chip causes latency spikes and drops.
- **BT/WiFi coexistence NVRAM** — the stock NVRAM had no `btc_mode`/`btc_params`,
  so Bluetooth lost every fight for the shared 2.4GHz antenna. The updated
  `brcmfmac43430a0-sdio.txt` enables coex arbitration and sets `ccode=US`.

---

## 🔄 Screen Auto-Rotation

The accelerometer (Kionix KIOX000A) mount matrix is installed by the main script
via `/etc/udev/hwdb.d/61-sensor-local.hwdb`, and the FTSC1000 touchscreen works
out of the box with `hid-multitouch` — on GNOME Wayland, touch input follows the
screen rotation automatically. If the screen does not auto-rotate, GNOME's
orientation lock is probably on. Turn it off (as your user, not root):

```bash
gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock false
```

The panel is portrait-native (1200x1920) and the tablet is portrait-natural,
so the boot console and login screen already render correctly — no
`panel_orientation` kernel quirk is needed. Only if you want the boot screen
in landscape instead, add `video=DSI-1:panel_orientation=right_side_up` (or
`left_side_up`) to the `options` line in `/boot/loader/entries/*.conf`.

---

## 🔆 Brightness / Night Light Fix

If brightness control is flaky and GNOME night light misbehaves, check `dmesg`
for `i915 ... Failed to get the SoC PWM chip`. i915 loads from the initramfs
but the Cherry Trail SoC PWM driver doesn't, so the DSI backlight probe fails
and the system falls back to broken `acpi_video*` firmware backlights. Fix:

```bash
sudo ./fix-backlight.sh   # adds pwm-lpss + pwm-lpss-platform to initramfs
```

Reboot and confirm `/sys/class/backlight/intel_backlight` exists.

---

## 📝 Notes & Troubleshooting

- `nuvision-tablet-drivers.sh` must be run with `sudo` (it does **not** escalate privileges itself).
- Firmware files are for Broadcom chips commonly found in NuVision tablets. If your hardware differs, you may need other firmware.
- For audio issues, check the `audio-drivers` folder for additional firmware or configuration scripts.
- If WiFi or Bluetooth does not work, verify that the correct firmware files are present in `/lib/firmware/` and that your kernel supports the device.
- For autostart issues, ensure `wifi-startup.desktop` is in the correct autostart directory and references the correct script path.

---

## 📄 License

MIT © PiercingXX
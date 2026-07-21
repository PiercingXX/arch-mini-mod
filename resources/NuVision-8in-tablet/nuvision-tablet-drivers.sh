#!/bin/bash
# Full driver + fix install for the NuVision 8" / TMAX TM800W610L tablet.
# Run as root: sudo ./nuvision-tablet-drivers.sh
# Reboot when it finishes.
set -uo pipefail
cd "$(dirname "$0")"

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo." >&2; exit 1; }
TARGET_USER="${SUDO_USER:-}"

# Packages
    pacman -S --needed --noconfirm linux-firmware broadcom-wl-dkms
    pacman -S --needed --noconfirm bluez bluez-utils
    pacman -S --needed --noconfirm sof-firmware alsa-utils
    pacman -S --needed --noconfirm iw wireless-regdb

# WiFi/Bluetooth firmware (incl. coex-enabled NVRAM) and audio firmware
    cp wifi-bluetooth-drivers/* /lib/firmware/brcm/
    cp audio-drivers/* /lib/firmware/intel/

# WiFi stability: roamoff + powersave off + coex NVRAM under both probe names
    bash ./fix-wifi-bt.sh

# WiFi survives suspend (sleep hook), in case suspend is ever re-enabled
    bash ./fix-suspend-wifi.sh

# Suspend is broken on this platform (WiFi never resumes, s2idle can crash
# the kernel) — disable it system-wide: GDM greeter + systemd sleep targets
    bash ./fix-disable-suspend.sh

# Brightness/night-light: pwm-lpss modules into initramfs before i915
    bash ./fix-backlight.sh

# Per-user settings: no suspend triggers in-session, enable auto-rotation
    if [ -n "$TARGET_USER" ]; then
        sudo -u "$TARGET_USER" dbus-run-session -- bash -c '
            gsettings set org.gnome.settings-daemon.plugins.power power-button-action nothing
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
            gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type nothing
            gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock false
        '
    else
        echo "WARN: could not determine invoking user; run the gsettings" \
             "commands from the README as your user." >&2
    fi

# Restart Bluetooth service
    systemctl restart bluetooth

# Touchscreen/accelerometer: hwdb file with correct mount matrix
tee /etc/udev/hwdb.d/61-sensor-local.hwdb > /dev/null <<EOF
sensor:modalias:acpi:KIOX000A*
 ACCEL_MOUNT_MATRIX=0,1,0;1,0,0;0,0,-1
EOF
# Update hardware database and reload sensor settings
    systemd-hwdb update
    udevadm trigger /sys/bus/iio/devices/iio:device0 2>/dev/null
    systemctl restart iio-sensor-proxy 2>/dev/null

echo ""
echo "All drivers and fixes installed. Reboot to apply."

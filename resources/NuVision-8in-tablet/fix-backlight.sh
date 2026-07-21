#!/bin/bash
# Backlight / night-light fix for Cherry Trail tablets with a DSI panel
# (NuVision 8" / TMAX TM800W610L).
#
# i915 loads from the initramfs (kms hook) but the SoC PWM driver does not,
# so the DSI backlight probe fails ("Failed to get the SoC PWM chip" in
# dmesg). The panel then falls back to non-functional acpi_video firmware
# backlight devices, which breaks brightness control and GNOME night light.
# Putting pwm-lpss + pwm-lpss-platform into the initramfs makes the PWM
# chip available before i915 probes, giving a working intel_backlight.
#
# Run as root: sudo ./fix-backlight.sh
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo." >&2; exit 1; }

if grep -qE '^MODULES=.*pwm-lpss-platform' /etc/mkinitcpio.conf; then
    echo "pwm modules already in mkinitcpio MODULES."
else
    sed -i -E 's/^MODULES=\(/MODULES=(pwm-lpss pwm-lpss-platform /' /etc/mkinitcpio.conf
fi
grep '^MODULES=' /etc/mkinitcpio.conf

mkinitcpio -P

echo "Done. Reboot, then check that /sys/class/backlight/intel_backlight exists."

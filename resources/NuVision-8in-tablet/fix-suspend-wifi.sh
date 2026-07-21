#!/bin/bash
# Fix WiFi dying after suspend on the BCM43430a0 (NuVision 8" / TMAX TM800W610L).
#
# The 43430a0 fails to re-probe on s2idle resume (dmesg shows
# "brcmf_ops_sdio_resume: Failed to probe device on resume", err -110),
# leaving WiFi dead until reboot. Reloading the driver around suspend
# forces a full clean re-probe of the SDIO card on wake.
#
# Also installs wireless-regdb (kernel logged "failed to load
# regulatory.db") and iw for diagnostics.
#
# Run as root: sudo ./fix-suspend-wifi.sh
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo." >&2; exit 1; }

tee /usr/lib/systemd/system-sleep/brcmfmac-reload.sh >/dev/null <<'EOF'
#!/bin/bash
# The BCM43430a0 SDIO WiFi fails to resume from s2idle (err -110);
# unload before sleep and re-probe on wake so it comes back alive.
case "$1" in
    pre)
        modprobe -r brcmfmac_wcc brcmfmac 2>/dev/null || true
        ;;
    post)
        modprobe brcmfmac || true
        ;;
esac
EOF
chmod 755 /usr/lib/systemd/system-sleep/brcmfmac-reload.sh

pacman -S --needed --noconfirm wireless-regdb iw || \
    echo "WARN: pacman install failed (offline?); rerun later." >&2

echo "Done. Takes effect on the next suspend — no reboot needed."

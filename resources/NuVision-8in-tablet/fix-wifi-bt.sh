#!/bin/bash
# WiFi/Bluetooth stability fix for the BCM43430a0 (AP6212) SDIO chip
# found in the NuVision 8" / TMAX TM800W610L tablets.
#
# What this fixes:
#   1. Random WiFi dropouts — the 2017-era 43430a0 firmware does in-firmware
#      roaming that crashes brcmfmac (brcmf_bss_roaming_done WARN in dmesg)
#      and kills the connection. roamoff=1 hands roaming to wpa_supplicant.
#   2. WiFi powersave on this SDIO chip causes latency spikes and drops.
#   3. Bluetooth stutter — the stock NVRAM has no BT/WiFi coexistence
#      parameters, so BT loses every fight for the shared 2.4GHz antenna.
#
# Run as root: sudo ./fix-wifi-bt.sh
set -euo pipefail
cd "$(dirname "$0")"

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo." >&2; exit 1; }

# 1. Disable in-firmware roaming
tee /etc/modprobe.d/brcmfmac.conf >/dev/null <<'EOF'
# 43430a0 firmware roam events crash brcmf_bss_roaming_done and drop the
# connection. Let wpa_supplicant handle roaming instead.
options brcmfmac roamoff=1
EOF

# 2. Disable WiFi powersave in NetworkManager
tee /etc/NetworkManager/conf.d/wifi-powersave-off.conf >/dev/null <<'EOF'
[connection]
wifi.powersave = 2
EOF

# 3. Install NVRAM with BT/WiFi coexistence enabled (btc_mode=1) and US
#    regulatory domain. Installed under both names brcmfmac probes for.
install -m644 wifi-bluetooth-drivers/brcmfmac43430a0-sdio.txt \
    /lib/firmware/brcm/brcmfmac43430a0-sdio.txt
install -m644 wifi-bluetooth-drivers/brcmfmac43430a0-sdio.txt \
    "/lib/firmware/brcm/brcmfmac43430a0-sdio.TMAX-TM800W610L.txt"

echo "Done. Reboot to load the new NVRAM and module options."

#!/bin/bash
# Fully disable suspend (NuVision 8" / TMAX TM800W610L).
#
# Suspend is broken on this platform: the BCM43430a0 WiFi never resumes
# (err -110) and s2idle can crash the kernel outright. The in-session
# GNOME triggers are disabled via user gsettings, but GDM's own settings
# daemon still idle-suspends at the login screen. This disables that and
# masks the systemd sleep targets so nothing can suspend the machine.
#
# Run as root: sudo ./fix-disable-suspend.sh
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo." >&2; exit 1; }

# GDM greeter: no idle suspend, no power-button suspend
mkdir -p /etc/dconf/db/gdm.d
tee /etc/dconf/db/gdm.d/05-no-suspend >/dev/null <<'EOF'
[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-type='nothing'
sleep-inactive-battery-type='nothing'
power-button-action='nothing'
EOF
dconf update

# Systemd: refuse suspend from any source
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

echo "Done. Suspend is fully disabled system-wide."

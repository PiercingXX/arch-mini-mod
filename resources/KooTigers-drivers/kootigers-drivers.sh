#!/bin/bash

# Enable Goodix GDIX1002 touchscreen (run as root)
set -uo pipefail

DEV_SYSPATH="/sys/bus/i2c/devices/i2c-GDIX1002:00"
# wait for device node
for i in {1..20}; do
  if [ -e "$DEV_SYSPATH" ]; then break; fi
  sleep 1
done
if [ ! -e "$DEV_SYSPATH" ]; then
  echo "Device $DEV_SYSPATH not found."
  exit 1
fi

# power on the device (ignore failures)
echo "Requesting runtime power on..."
echo on > "$DEV_SYSPATH/power/control" 2>/dev/null || true

# reload modules (ignore errors if not present)
echo "Reloading kernel modules..."
modprobe -r goodix_ts i2c_hid hid_multitouch 2>/dev/null || true
modprobe i2c_hid goodix_ts hid_multitouch

# reset the parent PCI adapter (intel-lpss) by unbind/bind of its driver
echo "Resetting parent PCI adapter (if present)..."
# resolve PCI device from sysfs path
pci_dev=$(readlink -f "$DEV_SYSPATH" | sed -n 's#.*\(/\(0000:[0-9a-f:.]\+\)\)/.*#\2#p')
if [ -n "$pci_dev" ]; then
  # find driver name
  drvpath="/sys/bus/pci/devices/$pci_dev/driver"
  if [ -e "$drvpath" ]; then
    driver=$(basename "$(readlink -f "$drvpath")")
    echo -n "$pci_dev" > "/sys/bus/pci/drivers/$driver/unbind" || true
    sleep 1
    echo -n "$pci_dev" > "/sys/bus/pci/drivers/$driver/bind" || true
  fi
fi

# give kernel a moment, then show recent Goodix messages
sleep 1
echo "Recent kernel messages (Goodix):"
dmesg | tail -n 80 | grep -i -E 'goodix|GDIX|Capacitive|i2c-13' || true

echo "Done. Verify with: sudo libinput list-devices | grep -A6 -i Goodix"

#!/bin/bash
# GitHub.com/PiercingXX

set -euo pipefail

ROTATION_VALUE=1
KERNEL_ARG="fbcon=rotate:${ROTATION_VALUE}"
GRUB_DEFAULT_FILE="/etc/default/grub"
GRUB_CFG_TARGET=""

log() {
    printf '%s\n' "$*"
}

apply_runtime_rotation() {
    if [ -w /sys/class/graphics/fbcon/rotate_all ]; then
        echo "$ROTATION_VALUE" | sudo tee /sys/class/graphics/fbcon/rotate_all >/dev/null
        log "Applied TTY rotation immediately via /sys/class/graphics/fbcon/rotate_all"
    else
        log "Runtime TTY rotation interface not available; persistence update will still be attempted"
    fi
}

find_grub_cfg_target() {
    if [ -f /boot/grub/grub.cfg ]; then
        GRUB_CFG_TARGET=/boot/grub/grub.cfg
        return 0
    fi

    if [ -f /boot/grub2/grub.cfg ]; then
        GRUB_CFG_TARGET=/boot/grub2/grub.cfg
        return 0
    fi

    return 1
}

persist_grub_rotation() {
    if [ ! -f "$GRUB_DEFAULT_FILE" ]; then
        log "Could not find $GRUB_DEFAULT_FILE; skipping persistent GRUB update"
        return 1
    fi

    if grep -Eq 'fbcon=rotate:[0-3]' "$GRUB_DEFAULT_FILE"; then
        sudo sed -Ei 's/fbcon=rotate:[0-3]/'"$KERNEL_ARG"'/g' "$GRUB_DEFAULT_FILE"
    elif grep -Eq '^GRUB_CMDLINE_LINUX_DEFAULT=".*"' "$GRUB_DEFAULT_FILE"; then
        sudo sed -Ei 's/^GRUB_CMDLINE_LINUX_DEFAULT="(.*)"$/GRUB_CMDLINE_LINUX_DEFAULT="\1 '"$KERNEL_ARG"'"/' "$GRUB_DEFAULT_FILE"
    elif grep -Eq '^GRUB_CMDLINE_LINUX=".*"' "$GRUB_DEFAULT_FILE"; then
        sudo sed -Ei 's/^GRUB_CMDLINE_LINUX="(.*)"$/GRUB_CMDLINE_LINUX="\1 '"$KERNEL_ARG"'"/' "$GRUB_DEFAULT_FILE"
    else
        printf '%s\n' "GRUB_CMDLINE_LINUX_DEFAULT=\"${KERNEL_ARG}\"" | sudo tee -a "$GRUB_DEFAULT_FILE" >/dev/null
    fi

    if find_grub_cfg_target; then
        sudo grub-mkconfig -o "$GRUB_CFG_TARGET" >/dev/null
        log "Persisted TTY rotation in GRUB via ${GRUB_CFG_TARGET}"
        return 0
    fi

    log "Updated $GRUB_DEFAULT_FILE but could not find grub.cfg target; regenerate GRUB config manually"
    return 1
}

main() {
    log "Rotating TTY 90 degrees clockwise"
    apply_runtime_rotation
    persist_grub_rotation || true
    log "Reboot required for boot-time TTY rotation to fully take effect"
}

main "$@"

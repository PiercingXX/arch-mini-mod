#!/usr/bin/env bash
set -euo pipefail

# Reproducible Canon D530 setup for Arch Linux
# - Installs Canon UFRII driver package from AUR
# - Ensures CUPS is enabled and running
# - Creates/updates a CUPS queue named Canon-D530
# - Sets Canon-D530 as default and optionally prints a test page

PRINTER_NAME="${PRINTER_NAME:-Canon-D530}"
DEVICE_URI="${DEVICE_URI:-cnusbufr2:/dev/usb/lp0}"
PREFERRED_PPD="${PREFERRED_PPD:-/usr/share/cups/model/CNRCUPSD560ZK.ppd}"
FALLBACK_PPD="${FALLBACK_PPD:-/usr/share/cups/model/CNRCUPSD560ZS.ppd}"
DRIVER_PACKAGE="${DRIVER_PACKAGE:-cnrdrvcups-lb-bin}"
RUN_TEST_PRINT="${RUN_TEST_PRINT:-1}"
APPLY_LIBREOFFICE_FLATPAK_FIX="${APPLY_LIBREOFFICE_FLATPAK_FIX:-1}"

log() {
  printf "\n[canon-d530-setup] %s\n" "$*"
}

die() {
  printf "\n[canon-d530-setup] ERROR: %s\n" "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

install_aur_pkg() {
  local pkg="$1"

  if command -v paru >/dev/null 2>&1; then
    log "Installing ${pkg} with paru"
    paru -S --needed --noconfirm "$pkg"
    return 0
  fi

  if command -v yay >/dev/null 2>&1; then
    log "Installing ${pkg} with yay"
    yay -S --needed --noconfirm "$pkg"
    return 0
  fi

  die "No AUR helper found (paru/yay). Install one, then rerun."
}

ensure_cups_running() {
  if ! pacman -Q cups >/dev/null 2>&1; then
    log "Installing CUPS"
    sudo pacman -S --needed --noconfirm cups
  fi

  log "Enabling and starting CUPS"
  sudo systemctl enable --now cups

  local state
  state="$(systemctl is-active cups || true)"
  [[ "$state" == "active" ]] || die "CUPS service is not active"
}

select_ppd() {
  if [[ -f "$PREFERRED_PPD" ]]; then
    printf "%s" "$PREFERRED_PPD"
    return 0
  fi

  if [[ -f "$FALLBACK_PPD" ]]; then
    printf "%s" "$FALLBACK_PPD"
    return 0
  fi

  die "No supported Canon D530 PPD found. Checked: $PREFERRED_PPD and $FALLBACK_PPD"
}

setup_queue() {
  local ppd="$1"

  log "Creating/updating queue ${PRINTER_NAME}"
  sudo lpadmin -p "$PRINTER_NAME" -E -v "$DEVICE_URI" -P "$ppd"
  sudo cupsenable "$PRINTER_NAME"
  sudo cupsaccept "$PRINTER_NAME"
  lpoptions -d "$PRINTER_NAME"
}

print_test_page() {
  if [[ "$RUN_TEST_PRINT" != "1" ]]; then
    log "Skipping test print (RUN_TEST_PRINT=$RUN_TEST_PRINT)"
    return 0
  fi

  log "Sending test print job"
  lp -d "$PRINTER_NAME" /etc/hosts >/dev/null
}

apply_libreoffice_flatpak_fix() {
  local app_id="org.libreoffice.LibreOffice"
  local lo_user_dir="${HOME}/.var/app/${app_id}/config/libreoffice/4/user"
  local ts

  if [[ "$APPLY_LIBREOFFICE_FLATPAK_FIX" != "1" ]]; then
    log "Skipping LibreOffice Flatpak fix (APPLY_LIBREOFFICE_FLATPAK_FIX=$APPLY_LIBREOFFICE_FLATPAK_FIX)"
    return 0
  fi

  if ! command -v flatpak >/dev/null 2>&1; then
    log "Flatpak not found; skipping LibreOffice Flatpak fix"
    return 0
  fi

  if ! flatpak info "$app_id" >/dev/null 2>&1; then
    log "LibreOffice Flatpak not installed; skipping Flatpak-specific fix"
    return 0
  fi

  log "Applying LibreOffice Flatpak CUPS compatibility overrides"
  flatpak override --user \
    --socket=cups \
    --filesystem=xdg-run/cups \
    --filesystem=/run/cups \
    --env=CUPS_SERVER=/run/cups/cups.sock \
    "$app_id"

  # Restart user portal services so new Flatpak overrides are picked up.
  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-gtk.service 2>/dev/null || true
  fi

  ts="$(date +%s)"
  if [[ -f "${lo_user_dir}/registrymodifications.xcu" ]]; then
    mv "${lo_user_dir}/registrymodifications.xcu" "${lo_user_dir}/registrymodifications.xcu.bak.${ts}"
  fi
  if [[ -f "${lo_user_dir}/psprint/psprint.conf" ]]; then
    mv "${lo_user_dir}/psprint/psprint.conf" "${lo_user_dir}/psprint/psprint.conf.bak.${ts}"
  fi

  log "LibreOffice Flatpak fix applied (restart LibreOffice if currently open)"
}

main() {
  require_cmd pacman
  require_cmd lpadmin
  require_cmd lpstat
  require_cmd lpoptions
  require_cmd systemctl

  log "Validating sudo access"
  sudo -v

  install_aur_pkg "$DRIVER_PACKAGE"
  ensure_cups_running

  local ppd
  ppd="$(select_ppd)"
  log "Using PPD: $ppd"

  setup_queue "$ppd"
  apply_libreoffice_flatpak_fix
  print_test_page

  log "Final status"
  lpstat -t

  log "Complete"
  cat <<EOF

Re-run anytime:
  ./install-canon-d530-arch.sh

Optional overrides:
  PRINTER_NAME=Canon-D530 DEVICE_URI=cnusbufr2:/dev/usb/lp0 ./install-canon-d530-arch.sh
  RUN_TEST_PRINT=0 ./install-canon-d530-arch.sh
  APPLY_LIBREOFFICE_FLATPAK_FIX=0 ./install-canon-d530-arch.sh

EOF
}

main "$@"

#!/usr/bin/env bash

set -uo pipefail

PRINTER_TARGET="${PRINTER_TARGET:-${1:-}}"
SET_DEFAULT_PRINTER="${SET_DEFAULT_PRINTER:-1}"

CANON_PRINTER_NAME="${CANON_PRINTER_NAME:-${PRINTER_NAME:-Canon-D530}}"
CANON_DEVICE_URI="${CANON_DEVICE_URI:-${DEVICE_URI:-}}"
CANON_PREFERRED_PPD="${CANON_PREFERRED_PPD:-${PREFERRED_PPD:-/usr/share/cups/model/CNRCUPSD560ZS.ppd}}"
CANON_FALLBACK_PPD="${CANON_FALLBACK_PPD:-${FALLBACK_PPD:-/usr/share/cups/model/CNRCUPSD560ZK.ppd}}"
CANON_DRIVER_PACKAGE="${CANON_DRIVER_PACKAGE:-${DRIVER_PACKAGE:-cnrdrvcups-lb-bin}}"
RUN_TEST_PRINT="${RUN_TEST_PRINT:-1}"
APPLY_LIBREOFFICE_FLATPAK_FIX="${APPLY_LIBREOFFICE_FLATPAK_FIX:-1}"

OMEZIZY_QUEUE_NAME="${OMEZIZY_QUEUE_NAME:-${QUEUE_NAME:-Omezizy_Label}}"
OMEZIZY_MODEL_NAME="${OMEZIZY_MODEL_NAME:-${MODEL_NAME:-XP-420B}}"
OMEZIZY_PAGE_SIZE="${OMEZIZY_PAGE_SIZE:-${DEFAULT_PAGE_SIZE:-w4h6}}"
OMEZIZY_RESOLUTION="${OMEZIZY_RESOLUTION:-${DEFAULT_RESOLUTION:-203dpi}}"
OMEZIZY_GAPS_HEIGHT="${OMEZIZY_GAPS_HEIGHT:-${DEFAULT_GAPS_HEIGHT:-3}}"
OMEZIZY_POST_ACTION="${OMEZIZY_POST_ACTION:-${DEFAULT_POST_ACTION:-TearOff}}"
OMEZIZY_PRINT_SPEED="${OMEZIZY_PRINT_SPEED:-${DEFAULT_PRINT_SPEED:-6}}"
OMEZIZY_DARKNESS="${OMEZIZY_DARKNESS:-${DEFAULT_DARKNESS:-12}}"

log() {
  printf '[printer-install] %s\n' "$*"
}

die() {
  printf '[printer-install] ERROR: %s\n' "$*" >&2
  exit 1
}

show_usage() {
  cat <<'EOF'
Usage:
  ./install-printers.sh canon-d530
  ./install-printers.sh omezizy

Targets:
  canon-d530    Install and configure the Canon D530 queue
  omezizy       Install and configure the Omezizy/XPrinter label queue

Examples:
  ./install-printers.sh canon-d530
  RUN_TEST_PRINT=0 ./install-printers.sh canon-d530
  CANON_DEVICE_URI=auto ./install-printers.sh canon-d530
  CANON_DEVICE_URI=cnusbufr2:/dev/usb/lp1 ./install-printers.sh canon-d530

  ./install-printers.sh omezizy
  OMEZIZY_MODEL_NAME=XP-420B ./install-printers.sh omezizy
  OMEZIZY_QUEUE_NAME=Shipping_Labels SET_DEFAULT_PRINTER=0 ./install-printers.sh omezizy

You can also set PRINTER_TARGET instead of passing a positional argument.
Legacy environment variable names from the old standalone scripts are still accepted.
EOF
}

prompt_for_target() {
  if [[ ! -t 0 ]]; then
    return 0
  fi

  printf 'Select printer target:\n'
  printf '  1) Canon D530\n'
  printf '  2) Omezizy label printer\n'
  printf '  0) Cancel\n'
  printf 'Choice: '

  local choice
  read -r choice

  case "$choice" in
    1)
      PRINTER_TARGET='canon-d530'
      ;;
    2)
      PRINTER_TARGET='omezizy'
      ;;
    0|'')
      PRINTER_TARGET='help'
      ;;
    *)
      die "Invalid selection: ${choice}"
      ;;
  esac
}

ensure_canon_backend_installed() {
  local backend_path='/usr/lib/cups/backend/cnusbufr2'

  if [[ -x "$backend_path" ]]; then
    return 0
  fi

  die "Canon backend not found/executable at ${backend_path}. Reinstall ${CANON_DRIVER_PACKAGE}."
}

find_existing_canon_uri() {
  lpstat -v 2>/dev/null | awk '/^device for / && /usb:\/\/Canon\/D530\/D560\?serial=/{print $NF; exit}'
}

find_canon_uri_from_lsusb() {
  local serial

  command -v lsusb >/dev/null 2>&1 || return 1

  serial="$(lsusb -v -d 04a9:2775 2>/dev/null | awk '/iSerial/{print $NF; exit}')"
  [[ -n "$serial" ]] || return 1

  printf 'usb://Canon/D530/D560?serial=%s&interface=1\n' "$serial"
}

find_canon_backend_uri() {
  local lp_node

  command -v udevadm >/dev/null 2>&1 || return 1

  for lp_node in /dev/usb/lp*; do
    [[ -e "$lp_node" ]] || continue

    if udevadm info -a -n "$lp_node" 2>/dev/null | grep -q 'ATTRS{idVendor}=="04a9"'; then
      printf 'cnusbufr2:%s\n' "$lp_node"
      return 0
    fi
  done

  return 1
}

find_canon_device_uri() {
  local uri

  if [[ -n "$CANON_DEVICE_URI" && "$CANON_DEVICE_URI" != 'auto' ]]; then
    printf '%s\n' "$CANON_DEVICE_URI"
    return 0
  fi

  uri="$(find_canon_backend_uri)"
  if [[ -n "$uri" ]]; then
    printf '%s\n' "$uri"
    return 0
  fi

  uri="$(find_existing_canon_uri)"
  if [[ -n "$uri" ]]; then
    printf '%s\n' "$uri"
    return 0
  fi

  uri="$(lpinfo -v 2>/dev/null | awk '/^direct usb:\/\/Canon\//{print $2; exit}')"
  if [[ -n "$uri" ]]; then
    printf '%s\n' "$uri"
    return 0
  fi

  uri="$(find_canon_uri_from_lsusb)"
  if [[ -n "$uri" ]]; then
    printf '%s\n' "$uri"
    return 0
  fi

  die 'Unable to resolve a Canon D530 device URI automatically. If multiple printers are attached, set CANON_DEVICE_URI explicitly and rerun.'
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

validate_sudo() {
  log 'Validating sudo access'
  sudo -v
}

find_aur_helper() {
  if command -v paru >/dev/null 2>&1; then
    printf 'paru\n'
    return 0
  fi

  if command -v yay >/dev/null 2>&1; then
    printf 'yay\n'
    return 0
  fi

  die 'No AUR helper found (paru/yay). Install one, then rerun.'
}

install_arch_packages() {
  if [[ "$#" -eq 0 ]]; then
    return 0
  fi

  log "Installing packages: $*"
  sudo pacman -S --needed --noconfirm "$@"
}

install_aur_package() {
  local package_name="$1"
  local aur_helper

  if pacman -Q "$package_name" >/dev/null 2>&1; then
    log "${package_name} already installed; skipping AUR helper"
    return 0
  fi

  aur_helper="$(find_aur_helper)"
  log "Installing ${package_name} with ${aur_helper}"
  "${aur_helper}" -S --needed --noconfirm "${package_name}"
}

ensure_cups_running() {
  log 'Enabling and starting CUPS'
  sudo systemctl enable --now cups.service

  local state
  state="$(systemctl is-active cups.service || true)"
  [[ "$state" == 'active' ]] || die 'CUPS service is not active'
}

set_default_printer() {
  local queue_name="$1"

  if [[ "$SET_DEFAULT_PRINTER" != '1' ]]; then
    log "Leaving default printer unchanged (SET_DEFAULT_PRINTER=${SET_DEFAULT_PRINTER})"
    return 0
  fi

  log "Setting ${queue_name} as the default printer"
  lpoptions -d "$queue_name"
}

select_canon_ppd() {
  if [[ -f "$CANON_PREFERRED_PPD" ]]; then
    printf '%s\n' "$CANON_PREFERRED_PPD"
    return 0
  fi

  if [[ -f "$CANON_FALLBACK_PPD" ]]; then
    printf '%s\n' "$CANON_FALLBACK_PPD"
    return 0
  fi

  die "No supported Canon D530 PPD found. Checked: $CANON_PREFERRED_PPD and $CANON_FALLBACK_PPD"
}

apply_libreoffice_flatpak_fix() {
  local app_id='org.libreoffice.LibreOffice'
  local lo_user_dir="${HOME}/.var/app/${app_id}/config/libreoffice/4/user"
  local timestamp

  if [[ "$APPLY_LIBREOFFICE_FLATPAK_FIX" != '1' ]]; then
    log "Skipping LibreOffice Flatpak fix (APPLY_LIBREOFFICE_FLATPAK_FIX=${APPLY_LIBREOFFICE_FLATPAK_FIX})"
    return 0
  fi

  if ! command -v flatpak >/dev/null 2>&1; then
    log 'Flatpak not found; skipping LibreOffice Flatpak fix'
    return 0
  fi

  if ! flatpak info "$app_id" >/dev/null 2>&1; then
    log 'LibreOffice Flatpak not installed; skipping Flatpak-specific fix'
    return 0
  fi

  log 'Applying LibreOffice Flatpak CUPS compatibility overrides'
  flatpak override --user \
    --socket=cups \
    --filesystem=xdg-run/cups \
    --filesystem=/run/cups \
    --env=CUPS_SERVER=/run/cups/cups.sock \
    "$app_id"

  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-gtk.service 2>/dev/null || true
  fi

  timestamp="$(date +%s)"
  if [[ -f "${lo_user_dir}/registrymodifications.xcu" ]]; then
    mv "${lo_user_dir}/registrymodifications.xcu" "${lo_user_dir}/registrymodifications.xcu.bak.${timestamp}"
  fi
  if [[ -f "${lo_user_dir}/psprint/psprint.conf" ]]; then
    mv "${lo_user_dir}/psprint/psprint.conf" "${lo_user_dir}/psprint/psprint.conf.bak.${timestamp}"
  fi

  log 'LibreOffice Flatpak fix applied (restart LibreOffice if currently open)'
}

print_canon_test_page() {
  if [[ "$RUN_TEST_PRINT" != '1' ]]; then
    log "Skipping test print (RUN_TEST_PRINT=${RUN_TEST_PRINT})"
    return 0
  fi

  log 'Sending Canon test print job'
  lp -d "$CANON_PRINTER_NAME" /etc/hosts >/dev/null
}

find_omezizy_printer_uri() {
  local uri

  uri="$(lpinfo -v 2>/dev/null | awk '/usb:\/\/\/D520\?serial=/{print $2; exit}')"
  if [[ -n "$uri" ]]; then
    printf '%s\n' "$uri"
    return 0
  fi

  uri="$(lpinfo -v 2>/dev/null | awk '/usb:\/\/\/.*LabelPrinter/{print $2; exit}')"
  if [[ -n "$uri" ]]; then
    printf '%s\n' "$uri"
    return 0
  fi

  die 'Unable to find a supported USB URI for the label printer. Check lpinfo -v or lsusb.'
}

configure_canon_d530() {
  local ppd canon_uri

  log 'Configuring Canon D530 printer'
  install_arch_packages cups usbutils
  ensure_cups_running
  require_cmd lpadmin
  require_cmd lpinfo
  require_cmd lpstat
  require_cmd lpoptions

  if command -v modprobe >/dev/null 2>&1; then
    sudo modprobe usblp || true
  fi

  install_aur_package "$CANON_DRIVER_PACKAGE"
  ensure_canon_backend_installed

  sudo systemctl restart cups.service

  ppd="$(select_canon_ppd)"
  canon_uri="$(find_canon_device_uri)"
  log "Using PPD: ${ppd}"
  log "Using Canon URI: ${canon_uri}"

  sudo lpadmin -x "$CANON_PRINTER_NAME" 2>/dev/null || true
  cancel -a "$CANON_PRINTER_NAME" 2>/dev/null || true
  sudo lpadmin -p "$CANON_PRINTER_NAME" -E -v "$canon_uri" -P "$ppd"

  if [[ "$canon_uri" == usb://* ]]; then
    sudo lpadmin -p "$CANON_PRINTER_NAME" -o usb-no-reattach-default=true
  fi

  sudo cupsenable "$CANON_PRINTER_NAME"
  sudo cupsaccept "$CANON_PRINTER_NAME"

  sleep 2
  log 'Reloading CUPS to persist printer configuration'
  sudo systemctl restart cups.service
  sleep 2
  sudo cupsenable "$CANON_PRINTER_NAME"
  sudo cupsaccept "$CANON_PRINTER_NAME"
  set_default_printer "$CANON_PRINTER_NAME"

  apply_libreoffice_flatpak_fix
  print_canon_test_page

  log 'Final Canon printer status'
  lpstat -t
}

configure_omezizy() {
  local printer_uri model_ppd

  log 'Configuring Omezizy label printer'
  install_arch_packages cups cups-filters ghostscript dpkg
  ensure_cups_running
  require_cmd lpadmin
  require_cmd lpinfo
  require_cmd lpoptions
  require_cmd lpstat

  install_aur_package xprinter-cups

  if systemctl is-enabled lprint.service >/dev/null 2>&1; then
    log 'Disabling lprint.service to avoid USB device contention'
    sudo systemctl disable --now lprint.service || true
  fi

  printer_uri="$(find_omezizy_printer_uri)"
  model_ppd="xprinter/${OMEZIZY_MODEL_NAME}.ppd.gz"

  log "Detected printer URI: ${printer_uri}"
  log "Configuring queue ${OMEZIZY_QUEUE_NAME} with model ${OMEZIZY_MODEL_NAME}"

  sudo lpadmin -x "$OMEZIZY_QUEUE_NAME" 2>/dev/null || true
  sudo lpadmin -p "$OMEZIZY_QUEUE_NAME" -E -v "$printer_uri" -m "$model_ppd"

  log 'Applying label defaults'
  lpoptions -p "$OMEZIZY_QUEUE_NAME" \
    -o PageSize="$OMEZIZY_PAGE_SIZE" \
    -o Resolution="$OMEZIZY_RESOLUTION" \
    -o PaperType=LabelGaps \
    -o GapsHeight="$OMEZIZY_GAPS_HEIGHT" \
    -o PostAction="$OMEZIZY_POST_ACTION" \
    -o PrintSpeed="$OMEZIZY_PRINT_SPEED" \
    -o Darkness="$OMEZIZY_DARKNESS"

  sudo cupsenable "$OMEZIZY_QUEUE_NAME"
  sudo cupsaccept "$OMEZIZY_QUEUE_NAME"
  set_default_printer "$OMEZIZY_QUEUE_NAME"

  log 'Final Omezizy printer status'
  lpstat -p "$OMEZIZY_QUEUE_NAME" -l
  lpstat -v | grep "$OMEZIZY_QUEUE_NAME" || true
  lpoptions -p "$OMEZIZY_QUEUE_NAME"

  log 'Print a label test page with:'
  printf 'lp -d %q /usr/share/cups/data/testprint\n' "$OMEZIZY_QUEUE_NAME"
}

normalize_target() {
  case "$1" in
    canon|cannon|canon-d530|d530)
      printf 'canon-d530\n'
      ;;
    omezizy|label|label-printer|xprinter)
      printf 'omezizy\n'
      ;;
    help|-h|--help)
      printf 'help\n'
      ;;
    *)
      printf '%s\n' "$1"
      ;;
  esac
}

main() {
  require_cmd sudo
  require_cmd pacman
  require_cmd systemctl

  PRINTER_TARGET="$(normalize_target "$PRINTER_TARGET")"

  if [[ -z "$PRINTER_TARGET" ]]; then
    prompt_for_target
    PRINTER_TARGET="$(normalize_target "$PRINTER_TARGET")"
  fi

  if [[ -z "$PRINTER_TARGET" || "$PRINTER_TARGET" == 'help' ]]; then
    show_usage
    exit 0
  fi

  validate_sudo

  case "$PRINTER_TARGET" in
    canon-d530)
      configure_canon_d530
      ;;
    omezizy)
      configure_omezizy
      ;;
    *)
      die "Unknown printer target: ${PRINTER_TARGET}"
      ;;
  esac

  log 'Complete'
}

main "$@"

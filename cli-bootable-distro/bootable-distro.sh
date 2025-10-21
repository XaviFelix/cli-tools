#!/usr/bin/env bash
set -euo pipefail

bold() { echo -e "\033[1m$*\033[0m"; }
info() { echo -e "\033[1;34m[*]\033[0m $*"; }
warn() { echo -e "\033[1;33m[!]\033[0m $*"; }
die() {
  echo -e "\033[1;31m[x]\033[0m $*" >&2
  exit 1
}
need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }

ZERO="yes"
if [[ "${1:-}" == "--nozero" ]]; then ZERO="no"; fi

need lsblk
need dd
need udisksctl
need wipefs
need awk
need findmnt
need blockdev
need udevadm

bold "=== Bootable USB Creator (safe) ==="

# 1) Pick ISO #TODO: fzf to distro directory
read -r -p "Enter full path to ISO file: " ISO_PATH
[[ -r "$ISO_PATH" ]] || die "ISO not readable: $ISO_PATH"
ISO_PATH="$(readlink -f "$ISO_PATH")"
ISO_SIZE=$(stat -Lc '%s' "$ISO_PATH")

# 2) Show disks
echo
lsblk -o NAME,MODEL,SIZE,TYPE,TRAN,RM,FSTYPE,MOUNTPOINT
echo

# 3) Pick device
read -r -p "Enter target USB device (e.g. /dev/sdX or /dev/nvme1n1): " USB_DEV
[[ -b "$USB_DEV" ]] || die "Not a block device: $USB_DEV"

# 4) Refuse to touch the root/system disk
# Determine root's parent disk (e.g., /dev/nvme0n1 from /dev/nvme0n1p2)
ROOT_SRC="$(findmnt -no SOURCE /)"
ROOT_DISK="$(lsblk -no PKNAME "$ROOT_SRC" 2>/dev/null || true)"
if [[ -n "$ROOT_DISK" ]]; then
  ROOT_DISK="/dev/$ROOT_DISK"
else
  # If PKNAME missing: fall back to stripping partition suffix
  ROOT_DISK="$(lsblk -no NAME "$(readlink -f "$ROOT_SRC")" | sed 's/[0-9]*$//')"
  ROOT_DISK="/dev/${ROOT_DISK}"
fi
if [[ "$(readlink -f "$USB_DEV")" == "$(readlink -f "$ROOT_DISK")" ]]; then
  die "Refusing to write to your root/system disk ($ROOT_DISK). Pick a USB device."
fi

# 5) Sanity: removable check
BASE="$(basename "$USB_DEV")"
if [[ -f "/sys/block/$BASE/removable" ]]; then
  REM="$(cat "/sys/block/$BASE/removable" || echo 0)"
  if [[ "$REM" != "1" ]]; then
    warn "$USB_DEV does not report as removable. Make absolutely sure this is the USB stick."
  fi
fi

# 6) Capacity check
USB_SIZE=$(blockdev --getsize64 "$USB_DEV")
if ((USB_SIZE <= ISO_SIZE)); then
  die "USB capacity ($(numfmt --to=iec "$USB_SIZE")) is not larger than ISO ($(numfmt --to=iec "$ISO_SIZE"))."
fi

# 7) Final, explicit confirmation
echo
bold "⚠️  WARNING: This will ERASE ALL DATA on $USB_DEV"
lsblk -o NAME,SIZE,TYPE,MODEL,FSTYPE,MOUNTPOINT "$USB_DEV" || true
read -r -p "Type the EXACT device path ($USB_DEV) to continue: " CONFIRM
[[ "$CONFIRM" == "$USB_DEV" ]] || die "Confirmation mismatch. Aborting."

# 8) Unmount any child partitions (handles /dev/sdX1 and /dev/nvmeYp1)
info "Unmounting any mounted partitions on $USB_DEV…"
while read -r mp; do
  [[ -n "$mp" ]] && sudo umount "$mp" || true
done < <(lsblk -nrpo MOUNTPOINT "$USB_DEV" | awk 'NF')

# 9) Nuke signatures and leading boot areas (optional)
info "Clearing filesystem signatures…"
sudo wipefs -a "$USB_DEV"
if [[ "$ZERO" == "yes" ]]; then
  info "Zeroing first 10 MiB to clear MBR/GPT/boot remnants…"
  sudo dd if=/dev/zero of="$USB_DEV" bs=1M count=10 status=progress conv=fsync
else
  info "Skipping zeroing (--nozero)."
fi
sudo udevadm settle

# 10) Write ISO
bold "Writing $(basename "$ISO_PATH") to $USB_DEV …"
sudo dd if="$ISO_PATH" of="$USB_DEV" bs=4M status=progress conv=fsync

# 11) power off
sync
sudo udevadm settle
if udisksctl power-off -b "$USB_DEV" >/dev/null 2>&1; then
  info "Safely powered off $USB_DEV."
else
  warn "Couldn't power off the device automatically. You can safely remove/replug it now."
fi

bold "✅ Done. USB should now be bootable."
echo "Tip: If the ISO publisher provides a checksum, verify it BEFORE burning:"
echo "  sha256sum $ISO_PATH"

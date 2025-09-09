#!/bin/bash

# === BOOTABLE USB MAKER ===

set -e # Exit on any error

# Function to print in bold
bold() { echo -e "\033[1m$1\033[0m"; }

bold "=== Bootable USB Creator ==="

# Ask for ISO path
read -p "Enter full path to ISO file: " ISO_PATH
if [[ ! -r "$ISO_PATH" ]]; then
  echo "Error: File does not exist."
  exit 1
fi

# Show all current block devices
echo
lsblk
echo

# Ask for target USB device
read -p "Enter target USB device (e.g. /dev/sdX): " USB_DEV
if [[ ! -b "$USB_DEV" ]]; then
  echo "Error: Device does not exist."
  exit 1
fi

# Confirm before destroying data
echo
bold "⚠️  WARNING: This will erase all data on $USB_DEV"
read -p "Type 'YES' to continue: " CONFIRM
if [[ "$CONFIRM" != "YES" ]]; then
  echo "Aborted."
  exit 0
fi

# Unmount just in case
sudo umount ${USB_DEV}?* || true

# Flash the ISO using dd
bold "Writing $ISO_PATH to $USB_DEV ..."
sudo dd if="$ISO_PATH" of="$USB_DEV" bs=4M status=progress oflag=sync

# Sync + finish
sync
bold "✅ Done. USB is now bootable!"

#!/bin/bash

function unmount_label() {
  if [[ -n "$DEVICE_PATH" ]]; then
    echo "Unmounting $DEVICE_PATH..."
    udisksctl unmount -b "$DEVICE_PATH"
  else
    echo "No device path provided and DEVICE_PATH is not set."
    exit 1
  fi
}

function mount_label() {
  if [[ -n "$DEVICE_PATH" ]]; then
    echo "Mounting $DEVICE_PATH..."
    udisksctl mount -b "$DEVICE_PATH"
  else
    echo "No device path provided and DEVICE_PATH is not set."
    exit 1
  fi
}

#TODO: Test this
function backup_resources() {
  local LABEL_PATH="/run/media/$USER/$LABEL"

  if [[ -e "$LABEL_PATH" ]]; then
    echo "The path exist: $LABEL_PATH"
  else
    echo "The path $LABEL_PATH does not exist"
  fi

}

# Main
if [[ "$#" -ne 1 ]]; then
  echo "Error using command"
  echo "Usage: save <device name>"
  exit 1
fi

# Name of flashdrive
LABEL="$1"

# Find device path
DEVICE_PATH=$(lsblk -o LABEL,PATH | grep "^$LABEL" | awk '{print $2}')

# Mount Device
if [[ -e "$DEVICE_PATH" ]]; then
  echo "$DEVICE_PATH is a valid block device"
  mount_label
  backup_resources
else
  echo "$LABEL Not found"
  exit 1
fi

#!/usr/bin/env bash

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

function backup_protocol() {
  local DIR_PATH="$1"

  if [[ -d "$DIR_PATH" ]]; then
    echo -e "Copying resources to $LABEL...\n"
    rsync -av --delete $HOME/{Documents,Downloads,Pictures,Programming,Todo,.zshrc,.config} "$DIR_PATH/"
    # cp -r * "$DIR_PATH"
    echo -e "\nFinished copying resources to $LABEL device"
  else
    echo "Problem copying resources to $LABEL device"
    exit 1
  fi

}

function check_label_path() {
  local LABEL_PATH="$1"

  if [[ -d "$LABEL_PATH" ]]; then
    backup_protocol "$LABEL_PATH"
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
  check_label_path "/run/media/$USER/$LABEL"
  unmount_label
else
  echo "$LABEL Not found"
  exit 1
fi

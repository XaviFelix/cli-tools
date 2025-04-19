#!/bin/bash

#TODO: Pass args (file or dir) that will be backed up

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

function list_dir() {
  echo
  ls -la "$1"
  echo -e "\nWhere would you like to save your data?"
}

function display_menu() {
  echo -e "\n1) Save here"
  echo "2) Change directory"
  echo "3) Previous directory"
  echo "4) Make directory"
  echo "5) Preview data"
  echo "6) Exit program"
}

function backup_protocol() {
  local LABEL_PATH="$1"
  local options=("Save here" "Change directory" "Previous directory" "Make directory" "Preview data" "Exit program")
  local DIR_PATH="$LABEL_PATH"
  list_dir "$DIR_PATH"

  select choice in "${options[@]}"; do

    case "$choice" in
    "Save here")
      if [[ -d "$DIR_PATH" ]]; then
        echo "Backing up all resources in $PWD"
        echo "Copying resources to $LABEL..."
        cp -r * "$DIR_PATH"
        echo "Finished copying resources to $LABEL device"
      else
        echo "Problem copying resources to $LABEL device"
        exit 1
      fi
      break
      ;;

    "Change directory")
      #NOTE: backing up the dir path if given path doesn't exist
      OLD_PATH="$DIR_PATH"
      local user_input
      read -e user_input
      DIR_PATH="${DIR_PATH}/${user_input}"
      if [[ -d "$DIR_PATH" ]]; then
        clear
        list_dir "$DIR_PATH"
      else
        clear
        echo -e "$user_input does not exist!\n"
        sleep 1
        DIR_PATH="$OLD_PATH"
        ls -la "$DIR_PATH"
      fi

      echo "You are here: $DIR_PATH"
      display_menu
      ;;

    "Previous directory")
      local dir_path="$DIR_PATH"
      dir_path=$(dirname "$dir_path")
      if [[ -d "$dir_path" && "$dir_path" == "$LABEL_PATH"* ]]; then
        DIR_PATH="$dir_path"
        echo
        ls -la "$DIR_PATH"
        echo "You are here: $DIR_PATH"
        display_menu
      else
        ls -la "$DIR_PATH"
        echo -e "\nYou are in the device root. Must remain in $LABEL file hierarchy"
        echo "You are here: $DIR_PATH"
        display_menu

      fi

      ;;

    "Make directory")
      local dir_name
      read -p "Enter a directory name: " dir_name

      if [[ -z "$dir_name" ]]; then
        echo "Error: Directory name connot be empty"
        exit 1
      fi

      if [[ "$dir_name" == /* || "$dir_name" == *../* ]]; then
        echo "Error: Invalid directory name. Do not use absoulte paths or '../'."
        exit 1
      fi

      mkdir -p "$DIR_PATH/$dir_name" || {
        echo "Failed to create directory: $dir_name"
      }
      list_dir "$DIR_PATH"
      echo "You are still here: $DIR_PATH"
      display_menu
      ;;

    "Preview data")
      ls -la "$PWD" | less
      ;;

    "Exit program")
      echo "Exiting program..."
      exit 1
      ;;

    *)
      echo "Invalid choice, please try again or press 5 to exit"
      ;;

    esac
  done
}

function check_label_path() {
  local LABEL_PATH="/run/media/$USER/$LABEL"

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
# TODO: Get the args here (should include the list of directories or files i want to back up)
# TODO: If arg is '.' then that means the entire directory gets backed up.
#       else if its just a list of argumetns, then hold those in a list so that i can copy
#       each individually to their destination

# Find device path
DEVICE_PATH=$(lsblk -o LABEL,PATH | grep "^$LABEL" | awk '{print $2}')

# Mount Device
if [[ -e "$DEVICE_PATH" ]]; then
  echo "$DEVICE_PATH is a valid block device"
  mount_label
  check_label_path
  unmount_label
else
  echo "$LABEL Not found"
  exit 1
fi

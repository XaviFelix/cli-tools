#!/bin/bash

#TODO: new option: back up one directory

#NOTE:: If the device is mounted and the commadn is ran
#       TODO: First check if the device is mounted, if it is then don't mount it
#             and continue with the copy command

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

#NOTE: This isn't being used. Save just in case
function interactive_prompt() {
  # Prompt
  isRunning=1
  while [ "$isRunning" -eq 1 ]; do
    echo -e "\n Where would you like to save your data?"
    echo "Press . for the current directory"
    echo "Or type the path of the desired destination"
    ls -la
    local user_input
    read -e user_input

    case $user_input in
    .)
      cp -r * "$LABEL_PATH"
      ;;
    # Need one for all the paths
    e)
      exit 1
      ;;
    *)
      echo "Invalid path, try again or press e to exit."
      ;;
    esac
  done

}

function list_dir() {
  echo
  ls -la "$1"
  echo -e "\nWhere would you like to save your data?"
}

# TODO: Not working, create a small script diong this behavior to get a better understanding
function make_dir() {
  local dir_name
  echo -n "directory name: "
  read -e dir_name
  mkdir "${1}/${dir_name}"
  list_dir "$1"
}

function display_menu() {
  echo -e "\n1) Backup here"
  echo "2) Change directory"
  echo "3) Previous directory"
  echo "4) Make directory"
  echo "5) Exit program"
}

function select_user_option() {
  local LABEL_PATH="$1"

  #TODO: Test if relative paths work
  #NOTE: Relateive paths work only for the 'Change directory' option
  local options=("Backup here" "Change directory" "Previous directory" "Make directory" "Exit program")
  local DIR_PATH="$LABEL_PATH"
  list_dir "$DIR_PATH"

  select choice in "${options[@]}"; do

    # TODO: Make sure the path is a valid path
    case "$choice" in
    "Backup here")
      echo "Backing up all resources in $PWD"
      echo "Copying resources to $LABEL..."
      cp -r * "$DIR_PATH"
      echo "Finished copying resources to $LABEL device"
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
        sleep 2
        DIR_PATH="$OLD_PATH"
        ls -la "$DIR_PATH"

        #NOTE: Good try, but not what i wanted, my dumbass lmao
        # DIR_PATH=$(dirname "$DIR_PATH")
      fi

      echo "You are here: $DIR_PATH"
      display_menu
      ;;

    #TODO: Ensure that it doesn't go past the DEVICE_PATH
    "Previous directory")
      DIR_PATH=$(dirname "$DIR_PATH")
      if [[ -d "$DIR_PATH" ]]; then
        echo
        ls -la "$DIR_PATH"
        echo "You are here: $DIR_PATH"
        display_menu
      else
        echo ""
      fi

      ;;

    "Make directory")
      make_dir "$DIR_PATH"
      echo "You are here: $DIR_PATH"
      display_menu
      ;;

    "Exit program")
      #TODO: Make this better
      echo "Exiting program..."
      exit 1
      ;;

    *)
      echo "Invalid choice or path, please try again or press q to exit"
      ;;

    esac
  done
}

#TODO: Test this
function backup_protocol() {
  local LABEL_PATH="/run/media/$USER/$LABEL"

  #NOTE: was -e in case it don't work with -d
  if [[ -d "$LABEL_PATH" ]]; then
    select_user_option "$LABEL_PATH"
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
  backup_protocol
  unmount_label
else
  echo "$LABEL Not found"
  exit 1
fi

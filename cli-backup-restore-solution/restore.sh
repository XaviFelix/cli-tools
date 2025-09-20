#!/bin/bash

#NOTE: Set-up
FILE_NAME="$1"
DST="$2"
LOG_FILE="$HOME/Programming/zsh_scripts/cli-backup-restore-solution/backup.log"

#NOTE: Exit guards
if [[ -z "$FILE_NAME" || -z "$DST" ]]; then
  echo "Usage: $0 <backup_file.tar.gz> <restore_destination>"
  exit 2
fi

if [[ ! -e "$FILE_NAME" ]]; then
  echo "$FILE_NAME does not exist"
  exit 1
fi

#NOTE: Edge-case and warning
if [[ ! -d "$DST" ]]; then
  echo "Destination $DST does not exist. Creating it..."
  mkdir -p "$DST"
fi

if [[ "$(ls -A "$DST")" ]]; then
  read -p "Warning: $DST is not empty. Continue? (y/n): " confirm
  [[ "$confirm" != "y" ]] && echo "Restore cancelled." && exit 3
fi

#NOTE: Command
tar -xzf "$FILE_NAME" -C "$DST"
RESULT=$?

#NOTE: log result
if [[ $RESULT -eq 0 ]]; then
  echo "[$(date)] Restore was successful: $FILE_NAME extracted to $DST" >>"$LOG_FILE"
else
  echo "[$(date)] Restore FAILED: $FILE_NAME" >>"$LOG_FILE"
fi

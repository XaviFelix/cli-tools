#!/bin/bash

#NOTE: Set-up
SRC="$1"
FILE_NAME="${SRC##*/}" # cuts file name from dir path with its extension
NAME="${FILE_NAME%.*}" # strips the extension leaving only name
DST="$2"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_NAME="${NAME}_backup_$TIMESTAMP.tar.gz"
LOG_FILE="$HOME/Programming/zsh_scripts/cli-backup-restore-solution/backup.log"

#NOTE: Exit guards
if [[ -z "$SRC" || -z "$DST" ]]; then
  echo "Usage: $0 /source/dir /backup/destination"
  exit 1
fi

if [[ ! -d "$SRC" ]]; then
  echo "Source directory does not exist: $SRC"
  exit 2
fi

#NOTE: Command
tar -czf "$DST/$BACKUP_NAME" -C "$SRC" .
RESULT=$?

#NOTE: log result
if [[ "$RESULT" -eq 0 ]]; then
  echo "[$(date)] Backup successful: $BACKUP_NAME" >>"$LOG_FILE"
  cat "$LOG_FILE"
  # echo "Log written to $LOG_FILE"
else
  echo "[$(date)] Backup FAILED: $SRC" >>"$LOG_FILE"
  echo "Log failed writing to dst: $LOG_FILE"
fi

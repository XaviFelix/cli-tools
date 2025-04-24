#!/usr/bin/env bash

set -euo pipefail

#TODO: Make sure concept is never zero
CONCEPT="${PWD##*/}"
source "$(dirname "$0")/../../lib.sh"
# set_up_source_tree "$CONCEPT"

#NOTE: assumes that these exist because they are supposed
#      to be created by 'set_up_source_tree' function
src="$PWD/src"
dst="$PWD/dst"

if [[ -d "$src" && -d "$dst" ]]; then
  #NOTE: a mirror perfect copy from src to dst
  rsync -av --delete $src/{bin,docs,.hidden_dir,.hidden_file} "$dst/"
  echo "Done"
else
  echo "Error finding directories:"
  echo "src: $src"
  echo "dst: $dst"
  exit 1
fi

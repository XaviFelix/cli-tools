#!/usr/bin/env bash
set -euo pipefail

create_source_tree() {
  local dst="$1"

  rm -rf "$dst"

  # create base directories
  mkdir -p \
    "$dst"/{docs,images,bin,logs} \
    "$dst"/images/{raw,edited}

  # seed with test files
  echo "Hello, world!" >"$dst/docs/readme.txt"
  echo "Log start: $(date)" >"$dst/logs/run.log"
  dd if=/dev/zero bs=1 count=1024 >"$dst/bin/zeros.bin"

  # create a symlink and a hard‑link
  ln -s docs/readme.txt "$dst/readme-link.txt"
  ln "$dst/docs/readme.txt" "$dst/docs/readme-hardlink.txt"

  # custom permissions
  chmod 600 "$dst/logs/run.log"
  touch -t 202001010101.01 "$dst/docs/readme.txt"

  echo "Prepared fresh source tree at: $dst"
}

set_up_source_tree() {
  #NOTE: This comes from the passed arg in the concept folder
  #      - Name of the folder from which the function is being called from
  CONCEPT="$1"

  #NOTE: cat is relative to the calling function not
  #      not where this particular funciton is defined or located from
  #
  # BASEPATH=$(cat ./tests/test_path)

  BASEPATH=$(cat ../test_path)
  src="$BASEPATH/$CONCEPT/src"
  dst="$BASEPATH/$CONCEPT/dst"

  create_source_tree "$src"

  rm -rf "$dst"
  mkdir -p "$dst"
}

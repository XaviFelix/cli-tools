#!/usr/bin/env bash
set -euo pipefail

create_source_tree() {
  local src="$1"

  rm -rf "$src"

  # create base directories
  mkdir -p \
    "$src"/{docs,images,bin,logs} \
    "$src"/images/{raw,edited}

  # seed with test files
  echo "Hello, world!" >"$src/docs/readme.txt"
  echo "Log start: $(date)" >"$src/logs/run.log"
  dd if=/dev/zero bs=1 count=1024 >"$src/bin/zeros.bin"

  # create a symlink and a hard‑link
  ln -s docs/readme.txt "$src/readme-link.txt"
  ln "$src/docs/readme.txt" "$src/docs/readme-hardlink.txt"

  # custom permissions
  chmod 600 "$src/logs/run.log"
  touch -t 202001010101.01 "$src/docs/readme.txt"

  echo "Prepared fresh source tree at: $src"
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
  #TODO: Change src to basepath/src so that we only copy from one tree and not multiple ones
  src="$BASEPATH/$CONCEPT/src"
  dst="$BASEPATH/$CONCEPT/dst"

  create_source_tree "$src"

  rm -rf "$dst"
  mkdir -p "$dst"
}

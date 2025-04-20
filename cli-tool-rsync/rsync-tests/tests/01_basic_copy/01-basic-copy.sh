#!/usr/bin/env bash

#TODO: This script has one arg
#      - The name of the direcotry which contians the test script
#
set -euo pipefail

#TODO: Make sure concept is never zero
CONCEPT="${PWD##*/}"
source "$(dirname "$0")/../../lib.sh"

set_up_source_tree "$CONCEPT"

#!/bin/bash

# TODO: Needs to support all dir and file types

ROOT_DIR="$HOME/dev-notebook"
CURRENT_DIR="$ROOT_DIR"

# Main navigation loop
while true; do
  cd "$CURRENT_DIR" || {
    echo "Error: Cannot access $CURRENT_DIR"
    exit 1
  }

  ITEMS=()
  if [ "$CURRENT_DIR" != "$ROOT_DIR" ]; then
    ITEMS+=("..")
  fi
  for item in *; do
    #TODO: remove this conditional
    if [ -d "$item" ] || [[ "$item" == *.md || "$item" == *.py || "$item" == *.rs || "$item" == *.sh || "$item" == *.txt ]]; then
      ITEMS+=("$item")
    fi
  done

  # Sort items alphabetically
  if [ ${#ITEMS[@]} -gt 0 ]; then
    if [ "${ITEMS[0]}" == ".." ]; then
      REST_ITEMS=("${ITEMS[@]:1}")
      mapfile -t SORTED_REST < <(printf '%s\n' "${REST_ITEMS[@]}" | sort)
      ITEMS=(".." "${SORTED_REST[@]}")
    else
      mapfile -t ITEMS < <(printf '%s\n' "${ITEMS[@]}" | sort)
    fi
  fi

  # The quit option
  ITEMS+=("Quit")

  # If no items
  if [ ${#ITEMS[@]} -eq 1 ]; then
    echo "No items found in $CURRENT_DIR"
    exit 0
  fi

  #TODO:: modify file extension chain
  PREVIEW_CMD='if [ -d {} ]; then if command -v tree >/dev/null 2>&1; then tree -C -L 2 {}; else ls -lh {}; fi; elif [[ {} == *.md || {} == *.py || {} == *.rs || {} == *.sh || {} == *.txt ]]; then bat --color=always --style=plain {}; else echo "No preview available"; fi'

  #NOTE: Bread and butter
  SELECTED=$(printf '%s\n' "${ITEMS[@]}" | fzf --layout=reverse --prompt="$(basename "$CURRENT_DIR") > " --preview="$PREVIEW_CMD" --preview-window=right:60%:wrap)

  # selection
  if [ -z "$SELECTED" ]; then
    # esc: exit
    exit 0
  elif [ "$SELECTED" == ".." ]; then
    # Go up one level
    CURRENT_DIR=$(dirname "$CURRENT_DIR")
  elif [ "$SELECTED" == "Quit" ]; then
    # quit
    exit 0
  elif [ -d "$SELECTED" ]; then
    # Navigate into selected dir
    CURRENT_DIR="$CURRENT_DIR/$SELECTED"
  elif [[ "$SELECTED" == *.md || "$SELECTED" == *.py || "$SELECTED" == *.rs || "$SELECTED" == *.sh || "$SELECTED" == *.txt ]]; then
    # Open file usnig nvim
    nvim "$SELECTED"
  fi
done

#!/usr/bin/env bash
set -euo pipefail

CATALOG="${CMDPAL_CATALOG:-$HOME/.cmdpal/commands.json}"

die() {
  echo "cmdpal error: $*" >&2
  exit 1
}
need() { command -v "$1" >/dev/null 2>&1 || die "missing dependency: $1"; }

need jq
need fzf

copy_clip() {
  if command -v wl-copy >/dev/null 2>&1; then
    wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
  else
    cat >/dev/null
    return 1
  fi
}

mkdir -p "$(dirname "$CATALOG")"
[ -f "$CATALOG" ] || { echo '{}' >"$CATALOG"; }

# Validate catalog JSON
jq . "$CATALOG" >/dev/null 2>&1 || die "Invalid catalog JSON. Try: jq . \"$CATALOG\""

ellipsize() {
  local s="$1" width="$2"
  local len=${#s}
  if ((len > width)); then
    printf "%s…" "${s:0:$((width - 1))}"
  else printf "%-*s" "$width" "$s"; fi
}

# confirm execution
confirm() {
  local prompt="${1:-Proceed?} [y/N]: "
  local ans=""
  if [[ -t 1 ]]; then printf "%s" "$prompt" >/dev/tty; fi
  IFS= read -r ans </dev/tty || true
  [[ "${ans:-}" =~ ^[Yy]([Ee][Ss])?$ ]]
}

#TODO: Loop can start here (requires 'back')

# Ensure catalog has topics
topics_count=$(jq 'keys|length' "$CATALOG")
((topics_count > 0)) || die "No topics found in $CATALOG"

# Pick topic
topic=$(jq -r 'keys[]' "$CATALOG" | fzf --prompt "Topic> " --height=80% --reverse) || exit 1

# TSV: NAME<TAB>DESC<TAB>COMMAND
tsv=$(jq -r --arg t "$topic" '.[$t][] | [.name, (.desc//""), (.command//"")] | @tsv' "$CATALOG")
[[ -n "$tsv" ]] || die "No commands under topic '$topic'."

# Build display list
list=$(
  while IFS=$'\t' read -r name desc cmd; do
    display="$(ellipsize "$name" 28)  $(ellipsize "$desc" 80)"
    printf "%s\t%s\t%s\t%s\n" "$display" "$name" "$desc" "$cmd"
  done <<<"$tsv"
)

# Pick a command
cmd_line=$(printf "%s\n" "$list" | fzf \
  --with-nth=1 --delimiter=$'\t' \
  --prompt "Command ($topic)> " \
  --preview-window=down:wrap:60% \
  --preview 'awk -F"\t" "{printf \"Name:  %s\nDesc:  %s\n\nCommand:\n%s\n\", \$2, \$3, \$4}" <<< "{}"' \
  --height=90% --reverse) || exit 1

# Extract fields
cmd_name=$(awk -F'\t' '{print $2}' <<<"$cmd_line")
cmd_desc=$(awk -F'\t' '{print $3}' <<<"$cmd_line")
cmd_raw=$(awk -F'\t' '{print $4}' <<<"$cmd_line")

echo "──────────────────────────────── COMMAND ────────────────────────────────"
echo "$cmd_raw"
echo "────────────────────────────────────────────────────────────────────────"
echo "Desc: ${cmd_desc:-N/A}"
echo

# menu
action=$(printf "print\ncopy\nedit\nexecute\ncancel" | fzf --prompt "Action> " --height=50% --reverse) || exit 0

case "$action" in
print)
  printf "%s\n" "$cmd_raw"
  ;;
copy)
  if copy_clip <<<"$cmd_raw"; then
    echo "[copied to clipboard]"
  else
    echo "[no clipboard tool found; printed instead]"
    printf "%s\n" "$cmd_raw"
  fi
  ;;
edit)
  tmpfile=$(mktemp /tmp/cmdpal.XXXXXX)
  printf "%s\n" "$cmd_raw" >"$tmpfile"
  "${EDITOR:-vi}" "$tmpfile"
  edited=$(cat "$tmpfile")
  rm -f "$tmpfile"
  echo "Edited command:"
  echo "$edited"
  if confirm "Execute edited command?"; then bash -lc "$edited"; fi
  ;;
execute)
  echo "About to execute:"
  echo "$cmd_raw"
  if confirm; then bash -lc "$cmd_raw"; fi
  ;;
*) ;;
esac

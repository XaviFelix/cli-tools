#!/bin/zsh

xcmd() {
  if (($# > 0)); then
    local -r PATTERN="$1"
    local RESULT="$(
      rg -lw "$PATTERN" ~/Documents/dev-commands/ |
        fzf --delimiter='/' --with-nth=-1 \
          --preview 'sh -c '"'"'
            pat="$1"; file="$2"
            ln="$(rg -in -m1 --color=never -- "$pat" "$file" | cut -d: -f1)"
            if [ -n "$ln" ]; then
              bat --style=numbers --color=always --paging=never --highlight-line "$ln" "$file"
            else
              bat --style=numbers --color=always --paging=never "$file"
            fi
          '"'"' sh "$PATTERN" {}
          ' --preview-window=down,60%,wrap
    )"

    if [[ -f "$RESULT" ]]; then
      n "$RESULT"
      return 0
    else
      return 1
    fi

  else
    ranger /home/xabi/Documents/dev-commands/
  fi
}

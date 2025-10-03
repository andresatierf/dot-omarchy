#!/usr/bin/zsh

local mise_path="$HOME/.local/bin/mise"

(( ${+commands[mise]} || $([[ -e $mise_path ]] && echo 1 || echo 0) )) && () {
  local command=${commands[mise]:-"$mise_path"}

  # generating activation file
  local initfile=$1/mise-activate.zsh
  if [[ ! -e $initfile || $initfile -ot $command ]]; then
    $command activate zsh >| $initfile
    zcompile -UR $initfile
    print -u2 -PR "* [mise] Generated init file."
  fi

  # generating completions
  local compfile=$1/functions/_mise
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
    mkdir -p "$(dirname $compfile)"
    $command complete --shell zsh >| $compfile
    print -u2 -PR "* [mise] Detected a new version 'mise'. Regenerated completions."
  fi

  source $initfile
} ${0:h}

#!/bin/zsh

(( ${+commands[gh]} || ${+commands[mise]} )) && () {

  local command=${commands[gh]:-"$(${commands[mise]} which gh 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating completions
  local compfile=$1/functions/_gh
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
    mkdir -p "$(dirname $compfile)"
    $command completion -s zsh >| $compfile
    print -u2 -PR "* [gh] Detected a new version 'gh'. Regenerated completions."
  fi
} ${0:h}

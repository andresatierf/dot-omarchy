#!/bin/zsh

(( ${+commands[restic]} || ${+commands[mise]} )) && () {
  local command=${commands[restic]:-"$(${commands[restic]} which restic 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating completions
  local compfile=$1/functions/_restic
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
    mkdir -p "$(dirname $compfile)"
    $command generate --zsh-completion "-" >| $compfile
    print -u2 -PR "* [restic] Detected a new version 'restic'. Regenerated completions."
  fi
} ${0:h}

#!/bin/zsh

(( ${+commands[delta]} || ${+commands[mise]} )) && () {

  local command=${commands[delta]:-"$(${commands[mise]} which delta 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating completions
  local compfile=$1/functions/_delta
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
    $command --generate-completion zsh >| $compfile
    print -u2 -PR "* [delta] Detected a new version 'delta'. Regenerated completions."
  fi

  alias diff="delta"

} ${0:h}

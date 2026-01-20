#!/bin/zsh

(( ${+commands[dotnet]} || ${+commands[mise]} )) && () {

  local command=${commands[dotnet]:-"$(${commands[mise]} which dotnet 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating completions
  local compfile=$1/functions/_dotnet
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
    mkdir -p "$(dirname $compfile)"
    $command completions script zsh >| $compfile
    print -u2 -PR "* [dotnet] Detected a new version 'dotnet'. Regenerated completions."
  fi
} ${0:h}


#!/bin/zsh

(( ${+commands[bat]} || ${+commands[batcat]} || ${+commands[mise]} )) && () {
  local command=${commands[bat]:-${+commands[batcat]:-"$(${commands[mise]} which bat 2> /dev/null)"}}
  [[ -z $command ]] && return 1

  # generating completions
  local compfile=$1/functions/_bat
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
    mkdir -p "$(dirname $compfile)"
    $command --completion zsh >| $compfile
    print -u2 -PR "* [bat] Detected a new version 'bat'. Regenerated completions."
  fi

  alias bat="$command --color=always"

  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"

  alias cat="bat"
} ${0:h}

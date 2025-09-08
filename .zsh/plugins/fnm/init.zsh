#!/bin/zsh

(( ${+commands[fnm]} || ${+commands[mise]} )) && () {

  local command=${commands[fnm]:-"$(${commands[mise]} which fnm 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating completions
  local compfile=$1/functions/_fnm
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
    $command completions --shell zsh >| $compfile
    print -u2 -PR "* [fnm] Detected a new version 'fnm'. Regenerated completions."
  fi

  # generating initfile
  local initfile=$1/fnm-init.zsh
  if [[ ! -e $initfile || $initfile -ot $command ]]; then
    $command env --use-on-cd >| $initfile
    zcompile -UR $initfile
  fi

  source $initfile
} ${0:h}

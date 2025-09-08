#!/bin/zsh

(( ${+commands[vivid]} || ${+commands[mise]} )) && () {

  local command=${commands[vivid]:-"$(${commands[mise]} which vivid 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating colors
  local colorfile=$1/vivid.zsh
  if [[ ! -e $colorfile || $colorfile -ot $command ]]; then
    $command generate tokyonight >| $colorfile
    print -u2 -PR "* [vivid] Detected a new version 'vivid'. Regenerated colors."
  fi

  export LS_COLORS=${LS_COLORS:-$(cat colorfile)}
} ${0:h}

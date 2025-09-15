#!/bin/zsh

(( ${+commands[starship]} || ${+commands[mise]} )) && () {

  local command=${commands[starship]:-"$(${commands[mise]} which starship 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating init file
  local initfile=$1/starship-init.zsh
  if [[ ! -e $initfile || $initfile -ot $command || $initfile -ot $HOME/.zshrc ]]; then
    $command init zsh  >| $initfile
    print -u2 -PR "* [starship] Detected a change to .zshrc. Regenerated init file."
    zcompile -UR $initfile
  fi

  source $initfile
} ${0:h}

#!/bin/zsh

(( ${+commands[oh-my-posh]} || ${+commands[mise]} )) && () {

  local command=${commands[oh-my-posh]:-"$(${commands[mise]} which oh-my-posh 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating init file
  local initfile=$1/oh-my-posh-init.zsh
  if [[ ! -e $initfile || $initfile -ot $command || $initfile -ot $HOME/.zshrc ]]; then
    local theme
    zstyle -a ":user:prompt:theme" theme "theme"
    $command init zsh --config ~/.config/ohmyposh/$theme.yaml >| $initfile
    print -u2 -PR "* [oh-my-posh] Detected a change to .zshrc. Regenerated init file."
    zcompile -UR $initfile
  fi

  # generating completions
  local compfile=$1/functions/_oh-my-posh
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
    $command completion zsh >| $compfile
    print -u2 -PR "* [oh-my-posh] Detected a new version 'oh-my-posh'. Regenerated completions."
  fi

  source $initfile
} ${0:h}

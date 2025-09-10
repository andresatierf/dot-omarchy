#!/bin/zsh

(( ${+commands[oh-my-posh]} || ${+commands[mise]} )) && () {

  local command=${commands[oh-my-posh]:-"$(${commands[mise]} which oh-my-posh 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating init file
  local initfile=$1/oh-my-posh-init.zsh
  if [[ ! -e $initfile || $initfile -ot $command || $initfile -ot $HOME/.zshrc ]]; then
    local theme
    zstyle -a ":user:prompt:theme" theme "theme"
    local config="$HOME/.config/ohmyposh/$theme.yaml"
    if [[ -f $config ]]; then
      $command init zsh --config $config >| $initfile
    else
      $command init zsh >| $initfile
    fi
    print -u2 -PR "* [oh-my-posh] Detected a change to .zshrc. Regenerated init file."
    zcompile -UR $initfile
  fi

  source $initfile
} ${0:h}

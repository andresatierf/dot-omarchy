#!/bin/zsh

(( ${+commands[oh-my-posh]} || ${+commands[mise]} )) && () {

  local command=${commands[oh-my-posh]:-"$(${commands[mise]} which oh-my-posh 2> /dev/null)"}
  [[ -z $command ]] && return 1

  local theme
  zstyle -a ":user:prompt:theme" theme "theme"
  local config="$HOME/.config/ohmyposh/$theme.yaml"

  # generating init file
  local initfile=$1/oh-my-posh-init.zsh
  if [[ ! -e $initfile || $initfile -ot $command || $initfile -ot $HOME/.zshrc ]]; then
    if [[ -f $config ]]; then
      $command init zsh --config $config >| $initfile
    else
      $command init zsh >| $initfile
    fi
    print -u2 -PR "* [oh-my-posh] Detected a change to .zshrc. Regenerated init file."
    zcompile -UR $initfile
  else if [[ -f $config && $initfile -ot $config ]]; then
    $command init zsh --config $config >| $initfile
    print -u2 -PR "* [oh-my-posh] Detected a change to config. Regenerated init file."
    zcompile -UR $initfile
  fi

  source $initfile
} ${0:h}

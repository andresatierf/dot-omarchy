#!/bin/zsh

(( ${+commands[zoxide]} || ${+commands[mise]} )) && () {

  local command=${commands[zoxide]:-"$(${commands[mise]} which zoxide 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating init file
  local initfile=$1/zoxide-init.zsh
  if [[ ! -e $initfile || $initfile -ot $command ]]; then
    local curr_version="$($command --version | cut -d' ' -f2)"
    local max_version="0.9.0"

    local lowest_version="$(printf '%s\n' "$max_version" "$curr_version" | sort -V | head -n1)"

    if [[ $lowest_version == $max_version ]]; then
      $command init --cmd cd zsh >| $initfile
    else
      $command init zsh >| $initfile
      alias cd="z"
      alias cdi="zi"
    fi

    zcompile -UR $initfile
  fi

  source $initfile
} ${0:h}

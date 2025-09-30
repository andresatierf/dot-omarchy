#!/bin/zsh

(( ${+commands[fzf]} || ${+commands[mise]} )) && () {

  local command=${commands[fzf]:-"$(${commands[mise]} which fzf 2> /dev/null)"}
  [[ -z $command ]] && return 1

  local curr_version="$(fzf --version)"
  local max_version="0.48.0"

  local lowest_version="$(printf '%s\n' "$max_version" "$curr_version" | sort -V | head -n1)"

  # generating initfile
  local initfile=$1/fzf-init.zsh
  if [[ ! -e $initfile || $initfile -ot $command ]]; then
    $command --zsh >| $initfile
    zcompile -UR $initfile
    print -u2 -PR "* [fzf] Generated init file."
  fi

  if [[ $lowest_version != "$max_version" ]]; then
    # generating completions
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    source /usr/share/doc/fzf/examples/completion.zsh
  fi

  export FZF_DEFAULT_OPTS='--height=20 --layout=reverse --ansi --color "fg:-1"'

  source $initfile
} ${0:h}

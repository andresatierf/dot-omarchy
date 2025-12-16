#!/bin/zsh

(( ${+commands[zellij]} || ${+commands[mise]} )) && () {
  local command=${commands[zellij]:-"$(${commands[mise]} which zellij 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating completions
  local compfile=$1/functions/_zellij
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
    mkdir -p "$(dirname $compfile)"
    $command setup --generate-completion zsh >| $compfile
    print -u2 -PR "* [zellij] Detected a new version 'zellij'. Regenerated completions."
  fi

  alias zj="$command"

  eval "
  zja() {
    local session=\$(zellij ls -r | fzf -- --header=\"Select a zellij session\" --accept-nth 1)
    [[ -n \$session ]] && $command a \"\$session\" || (echo \"No session selected\" && return 1)
  }
  "
} ${0:h}

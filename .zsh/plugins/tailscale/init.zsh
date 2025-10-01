
#!/bin/zsh

(( ${+commands[tailscale]} || ${+commands[mise]} )) && () {

  local command=${commands[tailscale]:-"$(${commands[mise]} which bat 2> /dev/null)"}
  [[ -z $command ]] && return 1

  # generating completions
  local compfile=$1/functions/_tailscale
  if [[ ! -e $compfile || $compfile -ot $command ]]; then
    $command completion zsh >| $compfile
    print -u2 -PR "* [tailscale] Detected a new version 'tailscale'. Regenerated completions."
  fi

} ${0:h}

#!/bin/zsh

# Simple command aliases
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias c='clear'
alias egrep='egrep --colour=auto'
alias extip='curl icanhazip.com'
alias lsmount='mount | column -t'
alias h='history -i 1'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'
alias ssha='eval $(ssh-agent) && ssh-add'
alias snvim='sudo -E nvim'
alias tn='tmux new -s'
alias weather='curl wttr.in'
alias colortest='sh <(curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh)'
alias gg='lazygit'
alias gd='lazygit --work-tree $DOTFILES --git-dir $DOTFILES/.git'

## Clear memory caches
alias dropcaches='su root -c "sync; echo 1 > /proc/sys/vm/drop_caches"'

# Custom command aliases
## Development
alias tmux:reload='tmux kill-server;sleep 1; tmux'

alias qr:decode="wl-paste | zbarimg -q --raw - | wl-copy"

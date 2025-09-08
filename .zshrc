#!/bin/zsh

# -----------------------------------------------------
# Zsh configuration
# -----------------------------------------------------
export ZSH_DIR="$HOME/.zsh"

# -----------------------------
# Input/output
# -----------------------------
bindkey -v

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# zsh-autosuggestions
ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# zsh-syntax-highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# ssh
zstyle ':zim:ssh' ids \
    'id_rsa' \
    'github_ed25519' \
    'tartarus_ed25519'

# path
zstyle ':zim:path' paths \
    "$HOME/bin" \
    "$HOME/.bin" \
    "$HOME/.local/bin" \
    "$HOME/.pub-cache/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.bun/bin" \
    "/var/lib/flatpak/exports/bin/" \
    "/usr/local/go/bin" \
    "$HOME/go/bin" \
    "$HOME/.local/share/bob/nvim-bin" \
    "/root/.local/bin"

# prompt
zstyle ':user:prompt:theme' theme 'zen' # options: p10k, zen

# -----------------------------------------------------
# Initialize modules
# -----------------------------------------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
    if (( ${+commands[curl]} )); then
        curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
    else
        mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
            https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
    fi
fi
# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
    source ${ZIM_HOME}/zimfw.zsh init -q
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# -----------------------------------------------------
# Post-init module configuration
# -----------------------------------------------------

# -----------------------------
# zsh-history-substring-search
# -----------------------------
zmodload -F zsh/terminfo +p:terminfo
# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

HISTFILE=~/.zsh_history

# Show system information at login when not in multiplexer
if { [ -t 0 ] && [ -z "$TMUX" ] && [ -z "$ZELLIJ" ]; } then
    if type -p "neofetch" > /dev/null; then
        neofetch
        return 0
    fi
    if type -p "fastfetch" > /dev/null; then
        fastfetch
    fi
fi

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
    'id_ed25519'

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
    "$HOME/.dotnet/tools"

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

# Show system information at login when not in a multiplexer.
# Disabled: uncomment the block to re-enable. Do NOT disable it with a bare
# `return` -- this is .zshrc top level, so returning aborts the rest of the
# file, which silently skipped everything below (uv env, wt, ccommit).
# if [ -t 0 ] && [ -z "$TMUX" ] && [ -z "$ZELLIJ" ]; then
#     if (( ${+commands[fastfetch]} )); then
#         fastfetch
#     elif (( ${+commands[neofetch]} )); then
#         neofetch
#     fi
# fi

[ -r "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi

# -----------------------------
# ccommit: AI-generated commit messages via claude (haiku)
# -----------------------------
ccommit() {
    local diff
    diff=$(git diff --cached)
    if [[ -z "$diff" ]]; then
        echo "ccommit: no staged changes" >&2
        return 1
    fi
    local contributing="" contributing_file
    for contributing_file in CONTRIBUTING.md contributing.md Contributing.md; do
        if [[ -f "$contributing_file" ]]; then
            contributing=$'\n\nFollow the contribution guidelines below:\n\n'"$(<"$contributing_file")"
            break
        fi
    done
    local msg
    msg=$(printf '%s\n' "$diff" | claude -p --model haiku \
        "Generate a concise git commit message for the following staged diff. Follow Conventional Commits (type(scope): subject). Output ONLY the commit message, no preamble, no code fences, no quotes.${contributing}") || return $?
    msg=${msg//\`\`\`/}
    msg=${msg##[[:space:]]}
    msg=${msg%%[[:space:]]}
    if [[ -z "$msg" ]]; then
        echo "ccommit: empty message from claude" >&2
        return 1
    fi
    echo "---"
    echo "$msg"
    echo "---"
    git commit -m "$msg" "$@"
}

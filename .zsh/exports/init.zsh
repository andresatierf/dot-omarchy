#!/bin/zsh

# Dotfiles location
export DOTFILES="$HOME/dot-omarchy"

# Terminal colors
# export TERM=xterm-256color

# -----------------------------
# Editor
# -----------------------------
# ~/.config/uwsm/default exports EDITOR for the graphical session; respect that
# and fall back here so SSH / TTY logins (which never source uwsm) get one too.
export EDITOR="${EDITOR:-nvim}"
export SUDO_EDITOR="$EDITOR"

# -----------------------------
# Misc
# -----------------------------
# Open URLs detached from the terminal's process tree (used by gh, etc).
# Shell-scoped on purpose: exporting BROWSER session-wide makes xdg-settings
# refuse to change the default browser.
if (( ${+commands[omarchy-launch-browser]} )); then
    export BROWSER="${BROWSER:-omarchy-launch-browser}"
fi

# Make bat follow the terminal's own theme
export BAT_THEME="${BAT_THEME:-ansi}"

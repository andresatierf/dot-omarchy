#!/bin/zsh

## Don't beep on error
setopt no_beep

# -----------------------------------------------------
# Directory
# -----------------------------------------------------
# Changing directories
unsetopt auto_cd

# Don't push multiple copies of the same directory onto the directory stack
setopt pushd_ignore_dups

# -----------------------------------------------------
# Completion
# -----------------------------------------------------
# show completion menu on successive tab press. needs unsetop menu_complete to work
setopt auto_menu

# any parameter that is set to the absolute name of a directory immediately becomes a name for that directory
setopt auto_name_dirs

# Allow completion from within a word/phrase
setopt complete_in_word

# do not autoselect the first completion entry
unsetopt menu_complete

# -----------------------------------------------------
# Expansion and globbing
# -----------------------------------------------------
# Stop annoying error when using asterisk in shell commands (i.e. scp server:*.txt .)
setopt nonomatch

# Execute the command directly upon history expansion.
unsetopt HIST_VERIFY

# -----------------------------------------------------
# Input/output
# -----------------------------------------------------
# spelling correction for commands
setopt nocorrect

# Allow comments even in interactive shells (especially for Muness)
setopt interactive_comments

# -----------------------------------------------------
# Prompting
# -----------------------------------------------------
## Turn on command substitution in the prompt (and parameter expansion and arithmetic expansion).
setopt promptsubst

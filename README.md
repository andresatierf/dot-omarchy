# Omarchy dotfiles

This repository contains my omarchy dotfiles

## Requirements

Ensure you have the following on your system

```sh
pacman -S git stow
```

## Installation

First, check out the dot-omarchy repo in your $HOME directory using git

```sh
git clone --recurse-submodules git@github.com:andresatierf/dot-omarchy.git
cd dot-omarchy
```

then use GNU stow to create symlinks

```sh
# dry run
stow --no-folding --adopt -v -n .

# execute
stow --no-folding --adopt -v .
```

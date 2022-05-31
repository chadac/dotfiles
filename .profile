#!/bin/sh

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# if running zsh
if [ -n "$ZSH_VERSION" ]; then
    if [ -f "$HOME/.zshrc" ]; then
        . "$HOME/.zshrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

# Default editor is emacs
export VISUAL='emacs -nw'
export EDITOR='emacs -nw'



# Flatpak
export PATH=/var/lib/flatpak/exports/bin:$HOME/.local/share/flatpak/exports/bin:$PATH

# asdf for tool version management
if [ -f "$HOME/.asdf/asdf.sh" ]; then
    source $HOME/.asdf/asdf.sh
fi
if [ -f "$HOME/.asdf/completions/asdf.bash" ]; then
    source $HOME/.asdf/completions/asdf.bash
fi

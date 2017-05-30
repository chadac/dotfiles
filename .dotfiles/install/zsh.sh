#!/bin/bash
## ZSH and Oh My ZSH

echo "Installing zsh..."
sudo apt-get install -y zsh

echo "Installing oh-my-zsh..."
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

## Move our .zshrc back
mv -f ~/.zshrc.pre-oh-my-zsh ~/.zshrc

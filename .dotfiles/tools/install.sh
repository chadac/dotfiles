#!/bin/bash

{
## Installs this dotfiles repo. There are a few dependencies that I
## need to add before I can start, so that's done here.
sudo apt-get install -y git curl python3

## Migration code from https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/

echo ".cfg" >> .gitignore
git clone --bare git@github.com:ChadACrawford/dotfiles.git $HOME/.cfg
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
config checkout -f master

echo "Finished! Start a new terminal session and run 'dotfiles install --all' to complete the setup."
}

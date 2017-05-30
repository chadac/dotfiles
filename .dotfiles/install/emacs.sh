#!/bin/bash
## Emacs and Cask.

echo "Installing emacs..."
sudo apt-get install -y emacs

## Cask is used for managing packages within Emacs
echo "Installing cask..."
curl -fsSL https://raw.githubusercontent.com/cask/cask/master/go | python

## Install all currently supported packages in cask
(
    cd ~/.emacs.d/
    ./.cask/bin/cask install
)

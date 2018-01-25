#!/bin/bash
## Xmonad, Xmobar, and Xfce4 if necessary

## Should install Xfce4 if necessary
echo "Installing Xfce4..."
sudo apt-get install -y xfce4 xfce4-terminal

echo "Installing Xmonad..."
sudo apt-get install -y xmonad

## TODO: Maybe switch to taffybar? https://github.com/travitch/taffybar
echo "Installing additional tools..."
sudo apt-get install -y trayer suckless-tools


## Installing additional dependencies for xmobar
sudo apt-get install -y cabal-install libasound-dev libiw-dev libghc-libxml-sax-dev c2hs libxpm-dev
cabal update && cabal install xmobar --fall_extensions

echo "Done! To use Xmonad, you will need to log out and log back in with Xfce4."

#!/bin/bash
## Xmonad, Xmobar, and Xfce4 if necessary

## Should install Xfce4 if necessary
echo "Installing Xfce4..."
sudo apt-get install -y xfce4

echo "Installing Xmonad..."
sudo apt-get install -y xmonad xmonad-contrib

## TODO: Maybe switch to taffybar? https://github.com/travitch/taffybar
echo "Installing Xmobar..."
sudo apt-get install -y xmobar

echo "Done! To use Xmonad, you will need to log out and log back in with Xfce4."

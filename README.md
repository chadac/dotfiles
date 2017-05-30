# Chad's Dotfiles

Configurations for various applications I use for Debian machines. My
setup is based on Xfce4 as my desktop manager and Xmonad as the window
manager and Emacs as my text editor.

It also has several installation scripts for other tools, which can
all be installed using a `dotfiles` script.

The setup is based on a
[great method by by Nicola Paolucci](https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/) that
doesn't require a script to copy dotfiles directory over.

## Installation

To install, run the following:

    curl -Lks https://raw.githubusercontent.com/ChadACrawford/dotfiles/master/.dotfiles/tools/install.sh | /bin/bash

Note that running this script will overwrite any shared files between
the two repos -- make backups as needed. Finally, once the script is
finished, restart your terminal session and run:

    dotfiles install --all

If you wish to select which utilities you want to install, run
`dotfiles install --help` to get a listing. Once it is complete, you
will probably need to log out for changes to take effect.

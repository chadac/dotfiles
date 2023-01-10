# @chadac's dotfiles

Pure Nix dotfile deployment! My descent into Nix continues...

This is a multi-host deployment for NixOS and Home Manager using
flakes. Largely influenced by [@lovesegfault's Nix
config](https://github.com/lovesegfault/nix-config).

The project is an experiment in trying to organize apps in a readable
fashion. Each program includes both Home Manager and NixOS configs in
the same file. They use host information provided in `./hosts` to
properly build the HM and NixOS configs.

## Installation

    nix run .# switch -- --flake .#<host>

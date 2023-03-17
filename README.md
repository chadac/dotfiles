# @chadac's dotfiles

Pure Nix dotfile deployment! My descent into Nix continues...

This is a multi-host deployment for NixOS and Home Manager using
flakes. Largely influenced by [@lovesegfault's Nix
config](https://github.com/lovesegfault/nix-config).

The project is an experiment in trying to organize apps in a readable
fashion. The `apps` folder is structured in a hierarchical fashion,
meaning that new hosts can be deployed by composing together a
tree-like structure of desired apps.

Additionally, each app contains both its needed overlays, its Home
Manager and its NixOS configurations. This enables me to organize my
configuration conceptually rather than functionally.

## Installation

    nix run .# switch -- --flake .#<host>

## Previous Iterations

Examples to use for reference in the future (potentially).

* [Generic Nix Setup + Hacky Git
  Config](https://github.com/chadac/dotfiles/tree/nix) - Back when I
  wasn't fully onboard the Nix bandwagon. Abandoned because
  [Flakes](https://nixos.wiki/wiki/Flakes) are just so much better.
* [Pre-Nix chezmoi
  setup](https://github.com/chadac/dotfiles/tree/main) - Generic
  dotfiles managed with chezmoi. Abandoned because I wanted to be able
  to capture more system configuration as code (especially my VFIO
  setup, which took days to replicate btw)
* [Even earlier iteration with installation
  scripts](https://github.com/chadac/dotfiles/tree/master) - I wrote
  my own setup scripts in Python. Abandoned because it was too
  Ubuntu-specific, and I moved to Arch.

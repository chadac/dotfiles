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

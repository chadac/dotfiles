# @chadac's dotfiles

Pure Nix dotfile deployment! My descent into Nix continues...

This is a multi-host deployment for NixOS and Home Manager using
flakes. Largely influenced by [@lovesegfault's Nix
config](https://github.com/lovesegfault/nix-config).

## Features

* Multi-host configuration with `flake-parts`: Each host deployment is
  its own flake created in `./make-host-config`, and then those are
  composed together using `flake-parts`. This makes it much easier for
  me to modularize my code.
* `apps`: Contains home-manager, NixOS and nixpkgs overlays all in one
  file. Organized by concept rather than function, so that I don't
  need to navigate to multiple directories at once.
* Multihead display configuration: Hosts can now specify a monitor
  configuration using standard `xrandr` outputs in a much more
  flexible fashion than what NixOS offers by default. I also include
  some Home Manager hooks so that display configurations can be
  applied at login on non-NixOS systems. See
  [./apps/desktop/wallpapers/default.nix](/apps/desktop/wallpapers/default.nix)
  for more details.

## Usage

For rebuilding NixOS:

    nix run .#nixos-rebuild switch -- --flake .#<host>

For rebuilding Home Manager:

    nix run .#home-manager switch -- --flake .#<host>

## TODO

* Flake integration tests via GitHub.
* Automated `flake update` CI task once a week.
* Explicit declarations of nonfree software used. I'll be aiming to
  eliminate nonfree software from my system entirely.
* Service for my hosts to self-update once a week.
* Entrypoint package to simplify executing `nixos-rebuild` and
  `home-manager`.
* Better QEMU virtual machine configuration. Currently there doesn't seem
  to be a way to deploy QEMU virtual machine XML configuration files
  via Nix directly, so I just need a script similar to what already
  exists for `libvirtd` that copies any machine configurations to
  `/var/lib/libvirtd/qemu.conf`.
* Multi-user configuration: Current setup is fairly opinionated about
  deploying to systems with a single user. It'd be nice to extend it
  for multi-user configurations, perhaps by splitting up the `host`
  configuration into separate `host` and `user` configurations...

## Previous Iterations

I've been maintaining my own dotfiles repo since around 2015-2016, but
my commit history is a bit dishonest because I usually reset the repo
from scratch when I decide to do total refactors. For those interested
in my historical configurations:

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

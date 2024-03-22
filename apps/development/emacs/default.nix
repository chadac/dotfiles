{ lib, inputs, ... }:
{
  nix-config.apps.emacs = {
    tags = [ "development" ];
    nixpkgs = { host, ... }: {
      params.overlays = lib.mkIf (!host.tags.minimal) [ inputs.emacs-overlay.overlay ];
    };
    home = import ./home.nix;
  };
}

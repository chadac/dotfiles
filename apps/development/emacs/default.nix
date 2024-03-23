{ lib, inputs, ... }:
{
  nix-config.apps.emacs = {
    tags = [ "development" ];
    nixpkgs = { host, ... }: {
      params.overlays = [ inputs.emacs-overlay.overlay ];
    };
    home = import ./home.nix;
  };
}

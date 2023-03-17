{
  host,
  nixpkgs,
  emacs-overlay,
  home-manager,
  apps,
  ...
}@inputs:
let
  pkgs = import ./nixpkgs.nix inputs;
  newInputs = inputs // { inherit pkgs; };
  flakeTypes = {
    nixos = import ./nixos.nix;
    home-manager = import ./home-manager.nix;
  };
in flakeTypes.${host.type} newInputs

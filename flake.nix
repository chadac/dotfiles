{
  description = "@chadac's dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ...}@inputs: 
    let
      inherit (nixpkgs) lib;
      inherit (builtins) listToAttrs map mapAttrs;
      hosts = import ./hosts;
      genHostOutput = import ./nix/combined.nix inputs;
      hostOutputs = mapAttrs (name: host: genHostOutput host) hosts;
      systems = lib.unique (lib.mapAttrsToList (_: host: host.system) hosts);
      getHostConfigurations = property: mapAttrs (name: value: value.${property})
        (lib.filterAttrs (n: v: v != null) hostOutputs);
    in {
      nixosConfigurations = getHostConfigurations "nixosConfiguration";
      homeConfigurations = getHostConfigurations "homeConfiguration";
      # devShells = getHostConfigurations "devShell";
    } // flake-utils.lib.eachSystem systems (system: {
      packages = {
        default = home-manager.defaultPackage.${system};
      };
    });
}

{ host, pkgs, apps }@args:
{ inputs, ... }:
let
  inherit (inputs) nixpkgs;
  inherit (pkgs) lib;
  nixosModules = import ./nixos-modules args;
in
{
  flake.nixosConfigurations.${host.hostname} = lib.mkIf (host.type == "nixos") (
    nixpkgs.lib.nixosSystem {
      inherit (host) system;

      inherit pkgs;

      modules = nixosModules;

      specialArgs = { inherit host; inherit inputs; inherit apps; inherit pkgs; };
    }
  );
}

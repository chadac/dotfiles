{ host, nixpkgs, pkgs, ... }@inputs:
let
  nixosModules = import ./nixos-modules inputs;
in
{
  flake.nixosConfigurations.${host.hostname} = nixpkgs.lib.nixosSystem {
    system = host.system;

    inherit pkgs;

    modules = nixosModules;

    specialArgs = { inherit host; inherit inputs; };
  };
}

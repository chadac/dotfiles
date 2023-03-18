{ host, pkgs, apps }@args:
{ inputs, ... }:
let
  inherit (inputs) home-manager;
in
{
  flake.homeConfigurations.${host.hostname} = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;

    modules = import ./home-modules args;

    extraSpecialArgs = { inherit host; inherit apps; };
  };
}

{ pkgs, host, home-manager, ... }:
{
  flake.homeConfigurations.${host.hostname} = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;

    modules = import ./home-modules;
  };
}

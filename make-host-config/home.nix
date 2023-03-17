{ host, pkgs, home-manager, ... }@inputs:
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = import ./home-modules;

  # extraSpecialArgs = builtins.trace (builtins.attrNames inputs) inputs;
}

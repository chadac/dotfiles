{ config, lib, flake-parts-lib, ... }:
let
  inherit (lib)
    mkOption
    types
  ;
  inherit (flake-parts-lib)
    mkSubmoduleOptions
  ;
in
{
  options = {
    flake = mkSubmoduleOptions {
      homeConfigurations = mkOption {
        type = types.lazyAttrsOf types.raw;
        default = { };
        description = ''
          Home configurations. Instantiated by home-manager build.
        '';
      };
    };
  };
}

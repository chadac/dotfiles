{ inputs, ... }:
let
  systems = [ "aarch64-darwin" ];
in
{
  imports = [
    ./aerospace
  ];

  nix-config.apps.darwin-defaults = {
    inherit systems;
    darwin = {
      nix.settings.trusted-users = [ "root" ];
      homebrew.enable = true;
    };
  };

  # sets up home-manager stuff to be discoverable
  # via launchpad
  nix-config.apps.mac-app-util = {
    inherit systems;
    home = {
      imports = [
        inputs.mac-app-util.homeManagerModules.default
      ];
    };
  };
}

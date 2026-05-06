{ ... }:
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
}

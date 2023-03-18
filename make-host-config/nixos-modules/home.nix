{ host, apps, inputs, ... }:
let
  inherit (inputs) pkgs home-manager;
in
{
  imports = [
    home-manager.nixosModules.home-manager {
      # Use nixos nixpkgs
      home-manager.useGlobalPkgs = true;
      # Install to /etc/profiles rather than $HOME/.nix-profile
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit host; inherit inputs; };
      home-manager.users.${host.username} = {
        imports = import ../home-modules ({ inherit apps; inherit host; inherit pkgs; });
      };
    }
  ];
}

# media server
{
  nix-config.hosts.nott = {
    kind = "nixos";
    system = "x86_64-linux";

    username = "chadac";
    email = "chad@cacrawford.org";
    homeDirectory = "/home/chadac";

    tags = {
      nvidia = true;
      bluetooth = true;
    };

    nixpkgs.packages.unfree = [ "nvidia-x11" "nvidia-settings" ];

    nixos = {};

    home = { pkgs, ... }: {};
  };
}

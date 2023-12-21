system:
{

  type = "nixos";
  inherit system;

  username = "chadac";
  email = "chad@cacrawford.org";
  homeDirectory = "/home/chadac";

  getApps = apps: [ apps.essential ];

  nixosConfiguration = { inputs, pkgs, ... }: {
    imports = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ];
    environment.systemPackages = with pkgs; [
      util-linux
      parted
    ];
  };
}

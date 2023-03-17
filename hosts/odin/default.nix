# My personal, primary desktop.
{
  type = "nixos";
  system = "x86_64-linux";

  username = "chadac";
  email = "chad@cacrawford.org";
  homeDirectory = "/home/chadac";

  allowUnfreePackages = [ "nvidia-x11" "nvidia-settings" ];

  getApps = apps: with apps; [ all ];

  nixosConfiguration = import ./nixos/configuration.nix;
}

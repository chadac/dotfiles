# My primary laptop.
{
  type = "nixos";
  system = "x86_64-linux";

  username = "chadac";
  email = "chad@cacrawford.org";
  homeDirectory = "/home/chadac";

  allowUnfreePackages = [ "nvidia-x11" "nvidia-settings" ];

  getApps = apps: [ apps.full ];
}

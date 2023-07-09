# My primary desktop.
{
  type = "nixos";
  system = "x86_64-linux";

  username = "chadac";
  email = "chad@cacrawford.org";
  homeDirectory = "/home/chadac";

  allowUnfreePackages = [ "nvidia-x11" "nvidia-settings" ];

  getApps = apps: [ apps.full apps.virt ];

  nixosConfiguration = import ./nixos/configuration.nix;

  displays = {
    HDMI-0 = {
      workspace = 1;
      mode = "2560x1440";
      pos = "0x0";
      rotate = "right";
    };
    DP-4 = {
      workspace = 2;
      mode = "2560x1440";
      pos = "1440x1120";
      rotate = "normal";
    };
    DP-0 = {
      workspace = 3;
      primary = true;
      mode = "2560x1440";
      pos = "4000x1120";
      rotate = "normal";
    };
    DVI-D-0.status = "off";
    DP-1.status = "off";
    DP-2.status = "off";
    DP-3.status = "off";
    DP-5.status = "off";
  };
}

# My primary desktop.
{
  nix-config.hosts.odin = {
    kind = "nixos";
    system = "x86_64-linux";

    username = "chadac";
    email = "chad@cacrawford.org";
    homeDirectory = "/home/chadac";

    tags = {
      desktop = true;
      gaming = true;
      virt = true;
    };

    nixpkgs.packages.unfree = [
      "nvidia-x11"
      "nvidia-settings"
    ];
    nixos = import ./nixos/configuration.nix;

    displays = {
      HDMI-0 = {
        workspace = 1;
        mode = "2560x1440";
        pos = "0x0";
        rotate = "right";
      };
      DP-0 = {
        workspace = 2;
        primary = true;
        mode = "2560x1440";
        pos = "1440x1120";
        rotate = "normal";
      };
      DP-2 = {
        workspace = 3;
        mode = "3840x2160";
        pos = "4000x760";
        scale = "0.75x0.75";
        rotate = "normal";
      };
      DP-1.enable = false;
      DP-3.enable = false;
      DP-4.enable = false;
      DP-5.enable = false;
    };
  };
}

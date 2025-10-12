# My primary desktop.
{ config, ... }:
let
  odin = {
    kind = "nixos";
    system = "x86_64-linux";

    username = "chadac";
    email = "chad@cacrawford.org";
    homeDirectory = "/home/chadac";

    tags = {
      desktop = true;
      gaming = true;
      virt = true;
      bluetooth = true;
      nvidia = true;
      x11 = true;
      wayland = false;
    };

    nix-config = {
      # disable podman in favor of dumb docker... for now
      apps.podman.enable = false;
    };

    nixpkgs.packages.unfree = [
      "libXNVCtrl"
      "nvidia-x11"
      "nvidia-settings"
      "hplip"
    ];
    nixos = ./nixos/configuration.nix;

    displays = {
      HDMI-0 = {
        workspace = 1;
        mode = "2560x1440";
        pos = "0x320";
        rotate = "right";
      };
      DP-0 = {
        workspace = 2;
        primary = true;
        mode = "2560x1440";
        pos = "1440x1440";
        rotate = "normal";
      };
      DP-2 = {
        workspace = 3;
        mode = "3840x2160";
        pos = "4000x1260";
        scale = "0.66x0.66";
        rotate = "normal";
      };
      DP-4 = {
        workspace = 4;
        mode = "2560x1440";
        pos = "1440x0";
      };
      DP-1.enable = false;
      DP-3.enable = false;
      DP-5.enable = false;
    };
  };
in {
  nix-config.hosts = {
    inherit odin;
    odin-darwin = odin // {
      kind = "darwin";
      system = "aarch64-darwin";

      displays = null;
      darwin = { lib, ... }: {
        system.primaryUser = lib.mkDefault "chadac";
      };
    };
  };
}

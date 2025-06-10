{ ... }:
let
  tags = [ "display" ];
  systems = [ "x86_64-linux" "aarch64-linux" ];
in
{
  imports = [
    ./i3
    ./Xresources
    ./wallpapers
    ./xserver
    ./xsession
  ];

  nix-config = {
    homeApps = [{
      inherit systems tags;
      packages = [
        "xterm"
        "firefox"
        "evince"
        "libnotify"
      ];
    }];

    apps.lightdm = {
      inherit systems tags;
      nixos = {
        services.xserver = {
          enable = true;
          displayManager.lightdm.enable = true;
        };
      };
    };

    apps.ristretto = {
      inherit systems tags;
      home = { pkgs, ... }: {
        home.packages = [ pkgs.xfce.ristretto ];
      };
    };

    apps.easyeffects = {
      inherit systems tags;
      home = {
        services.easyeffects.enable = true;
      };
    };

    apps.picom = {
      inherit systems tags;
      home = {
        services.picom = {
          enable = true;
          extraArgs = [ "--transparent-clipping" ];
        };
      };
    };

    apps.thunar = {
      inherit systems tags;
      home = { pkgs, ... }: {
        home.packages = [ pkgs.xfce.thunar ];
      };
      nixos = { pkgs, ... }: {
        programs.thunar = {
          enable = true;
          plugins = with pkgs.xfce; [
            thunar-archive-plugin
            thunar-volman
            thunar-media-tags-plugin
          ];
        };
      };
    };

    apps.tumbler = {
      inherit systems tags;
      home = { pkgs, ... }: {
        home.packages = [ pkgs.xfce.tumbler ];
      };
      nixos = {
        services.tumbler.enable = true;
      };
    };
  };
}

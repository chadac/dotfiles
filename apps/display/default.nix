{ lib, ... }:
let
  tags = [ "display" ];
  x11Tags = [ "x11" ];
  systems = [ "x86_64-linux" "aarch64-linux" ];
in
{
  imports = [
    ./x11
    ./wayland
    ./wallpapers
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
      inherit systems;
      tags = x11Tags;
      nixos = {
        services.xserver = {
          enable = true;
          displayManager.lightdm.enable = true;
        };
      };
    };

    apps.ristretto = {
      inherit systems;
      tags = x11Tags;
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

    # Redshift: shifts screen color temperature warmer at night.
    # Default-disabled; enable per-host with `apps.redshift.enable = true`
    # and override the placeholder latitude/longitude below.
    apps.redshift = {
      inherit systems;
      tags = x11Tags;
      enable = lib.mkDefault false;
      home = { lib, ... }: {
        services.redshift = {
          enable = true;
          # Default coordinates — override per host if needed.
          latitude = lib.mkDefault 26.1418617;
          longitude = lib.mkDefault (-80.1228234);
          temperature = {
            day = lib.mkDefault 6500;
            night = lib.mkDefault 3700;
          };
        };
      };
    };

    apps.picom = {
      inherit systems;
      tags = x11Tags;
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

    apps.display-base = {
      inherit systems tags;
      home = { pkgs, config, ... }: {
        xdg = {
          enable = true;
          mime.enable = true;
        };
        home.activation = {
          linkDesktopApplications = {
            after = [ "writeBoundary" "createXdgUserDirectories" ];
            before = [ ];
            data = ''
              rm -rf ${config.xdg.dataHome}/"applications/home-manager"
              mkdir -p ${config.xdg.dataHome}/"applications/home-manager"
              if [ -d ${config.home.homeDirectory}/.nix-profile/share/applications ]; then
                cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/"applications/home-manager/"
              fi
            '';
          };
        };
      };
    };
  };
}

{ ... }:
let
  tags = [ "display" ];
in
{
  nix-config = {
    defaultTags.display = true;

    homeApps = [{
      inherit tags;
      packages = [
        "xterm"
        "firefox"
        "evince"
      ];
    }];

    apps.lightdm = {
      inherit tags;
      nixos = {
        services.xserver = {
          enable = true;
          displayManager.lightdm.enable = true;
        };
      };
    };

    apps.ristretto = {
      inherit tags;
      home = { pkgs, ... }: {
        home.packages = [ pkgs.xfce.ristretto ];
      };
    };
    apps.thunar = {
      inherit tags;
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
      inherit tags;
      home = { pkgs, ... }: {
        home.packages = [ pkgs.xfce.tumbler ];
      };
      nixos = {
        services.tumbler.enable = true;
      };
    };
  };
}

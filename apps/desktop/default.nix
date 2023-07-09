{ call, mkApp, homePackage }:
{
  wallpapers = call ./wallpapers { };
  i3 = call ./i3 { };

  xserver = call ./xserver { };
  xsession = call ./xsession { };
  Xresources = call ./Xresources { };

  lightdm = mkApp {
    src = ./.;
    nixos = { inputs, ... }:
      let
        inherit (inputs) pkgs;
      in
        {
          services.xserver = {
            displayManager.lightdm.enable = true;
          };
        };
  };

  xterm = homePackage ./. "xterm";
  firefox = homePackage ./. "firefox";
  evince = homePackage ./. "evince";

  thunar = mkApp {
    src = ./.;
    home = { pkgs, ... }: {
      home.packages = [ pkgs.xfce.thunar ];
    };
    nixos = { pkgs, ... }: {
      programs.thunar.plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
      services.tumbler.enable = true;
    };
  };
  ristretto = mkApp {
    src = ./.;
    home = { pkgs, ... }: { home.packages = [ pkgs.xfce.ristretto ]; };
  };
  tumbler = mkApp {
    src = ./.;
    home = { pkgs, ... }: { home.packages = [ pkgs.xfce.tumbler ]; };
  };
}

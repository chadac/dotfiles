{ call, mkApp, homePackage }:
{
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
}

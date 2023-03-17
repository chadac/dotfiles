{ call, mkApp, homePackage }:
{
  i3 = call ./i3 { };
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
            enable = true;
            displayManager.lightdm.enable = true;
          };
        };
  };

  xterm = homePackage ./. "xterm";
}

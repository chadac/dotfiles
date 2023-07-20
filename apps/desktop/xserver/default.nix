{ mkApp, nixpkgs }:
let
  inherit (builtins)
    concatStringsSep
    hasAttr
  ;
  inherit (nixpkgs) lib;
  inherit (lib)
    mapAttrsToList
  ;
  mkXrandrCmd = xrandr: displays: concatStringsSep " \\\n" (
    [ "${xrandr}/bin/xrandr" ]
    ++ (mapAttrsToList (output: display:
      "   --output ${output}"
      + (if(hasAttr "status" display) then " --off" else "")
      + (if(hasAttr "mode" display) then " --mode ${display.mode}" else "")
      + (if(hasAttr "pos" display) then " --pos ${display.pos}" else "")
      + (if(hasAttr "scale" display) then " --scale ${display.scale}" else "")
      + (if(hasAttr "rotate" display) then " --rotate ${display.rotate}" else "")
      + (if(hasAttr "primary" display && display.primary) then " --primary" else "")
    ) displays)
    ++ [ " 2> /var/log/screenlayout.log || true" ]
  );
in
mkApp {
  src = ./.;
  nixos = { host, pkgs, ... }: {
    services.xserver = {
      enable = true;
      # xrandrHeads is another option, but it's too opinionated when your
      # setup is not chaining desktops left-to-right. Can't change that
      # without an upstream PR, so the temporary workaround is a separate call
      # to xrandr right after starting the xserver.
      displayManager.setupCommands =
        lib.mkIf (hasAttr "displays" host)
          (mkXrandrCmd pkgs.xorg.xrandr host.displays);
    };
  };
  home = { host, pkgs, ...}: {
    # Set up a service to configure the displays if it we're not on a NixOS system
    xsession.initExtra =
      lib.mkIf (host.type == "home-manager" && hasAttr "displays" host)
      (lib.mkBefore # Make this the highest priority item
        (mkXrandrCmd pkgs.xorg.xrandr host.displays));
  };
}

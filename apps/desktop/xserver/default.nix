{ mkApp }:
mkApp {
  src = ./.;
  nixos = { host, pkgs, ... }:
    let
      inherit (builtins)
        concatStringsSep
        hasAttr
      ;
      inherit (pkgs) lib;
      inherit (lib) mapAttrsToList;
      mkXrandrCmd = displays: concatStringsSep " \\\n" (
        [ "${pkgs.xorg.xrandr}/bin/xrandr" ]
        ++ (mapAttrsToList (output: display:
          "   --output ${output}"
          + (if(hasAttr "status" display) then " --off" else "")
          + (if(hasAttr "mode" display) then " --mode ${display.mode}" else "")
          + (if(hasAttr "pos" display) then " --pos ${display.pos}" else "")
          + (if(hasAttr "rotate" display) then " --rotate ${display.rotate}" else "")
          + (if(hasAttr "primary" display && display.primary) then " --primary" else "")
        ) displays)
      );
    in {
      services.xserver = {
        enable = true;
        # xrandrHeads is another option, but it's too opinionated when your
        # setup is not chaining desktops left-to-right. Can't change that
        # without an upstream PR, so the temporary workaround is a separate call
        # to xrandr right after starting the xserver.
        displayManager.setupCommands =
          lib.mkIf (hasAttr "displays" host) (mkXrandrCmd host.displays);
      };
    };
}

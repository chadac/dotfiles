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
        ) displays)
      );
    in {
      services.xserver = {
        enable = true;
        displayManager.setupCommands =
          lib.mkIf (hasAttr "displays" host) (mkXrandrCmd host.displays);
            # let output = (mkXrandrCmd host.displays); in builtins.trace output output);
      };
    };
}

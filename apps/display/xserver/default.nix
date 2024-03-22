{ lib, ... }:
let
  inherit (lib)
    concatStringsSep
    hasAttr
    mapAttrsToList
    mkOption
    types
  ;
  hostType = types.submodule {
    options = {
      displays = mkOption {
        default = { };
        type = types.lazyAttrsOf (types.submodule {
          options = {
            enable = mkOption { type = types.bool; default = true; };
            mode = mkOption { type = types.nullOr types.str; default = null; };
            pos = mkOption { type = types.nullOr types.str; default = null; };
            rotate = mkOption { type = types.nullOr types.str; default = null; };
            scale = mkOption { type = types.nullOr types.str; default = null; };
            primary = mkOption { type = types.bool; default = false; };

            # i3 compat
            workspace = mkOption { type = types.nullOr types.int; default = null; };
          };
        });
      };
    };
  };

  mkXrandrCmd = xrandr: displays: concatStringsSep " \\\n" (
    [ "${xrandr}/bin/xrandr" ]
    ++ (mapAttrsToList (output: display:
      "   --output ${output}"
      + (if(display.enable) then "" else " --off")
      + (if(display.mode != null) then " --mode ${display.mode}" else "")
      + (if(display.pos != null) then " --pos ${display.pos}" else "")
      + (if(display.scale != null) then " --scale ${display.scale}" else "")
      + (if(display.rotate != null) then " --rotate ${display.rotate}" else "")
      + (if(display.primary) then " --primary" else "")
    ) displays)
    ++ [ " 2> /var/log/screenlayout.log || true" ]
  );
in
{
  options = {
    nix-config.hosts = mkOption {
      type = types.attrsOf hostType;
    };
  };

  config = {
    nix-config.apps.xserver = {
      tags = [ "display" ];
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
          lib.mkIf (host.kind == "home-manager")
          (lib.mkBefore # Make this the highest priority item
            (mkXrandrCmd pkgs.xorg.xrandr host.displays));
      };
    };
  };
}

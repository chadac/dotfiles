{ lib, ... }:
let
  inherit (lib)
    mkOption
    types
  ;
  colorType = types.str;
  mkColorOption = description: mkOption {
    inherit description;
    type = colorType;
  };
  themeType = types.submodule ({ config, ... }: {
    options = {
      background = mkColorOption "background";
      foreground = mkColorOption "foreground (text) color";

      # xterm color palette
      color0 = mkColorOption "color0";
      color1 = mkColorOption "color1";
      color2 = mkColorOption "color2";
      color3 = mkColorOption "color3";
      color4 = mkColorOption "color4";
      color5 = mkColorOption "color5";
      color6 = mkColorOption "color6";
      color7 = mkColorOption "color7";
      color8 = mkColorOption "color8";
      color9 = mkColorOption "color9";
      color10 = mkColorOption "color10";
      color11 = mkColorOption "color11";
      color12 = mkColorOption "color12";
      color13 = mkColorOption "color13";
      color14 = mkColorOption "color14";
      color15 = mkColorOption "color15";
    };

    config = {
      background = lib.mkDefault config.color0;
      foreground = lib.mkDefault config.color7;
    };
  });
in
{
  options = {
    nix-config.theme = mkOption {
      type = themeType;
      description = ''
        The default theme used for coloring any applications.
      '';
    };
  };
}

{ lib }:
let
  inherit (lib)
    concatStringsSep
    mapAttrsToList
    replaceStrings
    head
    splitString
    filterAttrs
  ;
  
  # Convert position format from "XxY" to "X,Y" for kanshi
  formatPosition = pos: 
    if pos == null then null
    else replaceStrings ["x"] [","] pos;
    
  # Convert scale format from "AxB" to "A" for kanshi (takes first value)
  formatScale = scale:
    if scale == null then null
    else head (splitString "x" scale);
    
  # Convert xrandr-style rotation names to kanshi transform values
  transformMap = {
    right = "90";
    left = "270";
    inverted = "180";
    normal = "normal";
  };
  
  formatTransform = rotate:
    if rotate == null then "normal"
    else transformMap.${rotate} or rotate;
in
{
  # Generate kanshi configuration for persistent display management
  mkKanshiConfig = displays: 
    let
      enabledDisplays = lib.filterAttrs (output: display: display.enable or true) displays;
      primaryDisplay = lib.filterAttrs (output: display: (display.enable or true) && (display.primary or false)) displays;
      
      mainProfile = concatStringsSep "\n" (
        [ "profile \"main\" {" ]
        ++ (mapAttrsToList (output: display:
          "  output \"${output}\""
          + (if display.mode or null != null then " mode ${display.mode}" else "")
          + (if display.pos or null != null then " position ${formatPosition display.pos}" else "")
          + (if display.scale or null != null then " scale ${formatScale display.scale}" else "")
          + " transform ${formatTransform (display.rotate or null)}"
        ) enabledDisplays)
        ++ [ "}" ]
      );
      
      primaryProfile = if primaryDisplay != {} then
        concatStringsSep "\n" (
          [ "profile \"primary-only\" {" ]
          ++ (mapAttrsToList (output: display:
            "  output \"${output}\""
            + (if display.mode or null != null then " mode ${display.mode}" else "")
            + " transform ${formatTransform (display.rotate or null)}"
          ) primaryDisplay)
          ++ [ "}" ]
        )
      else "";
      
      fallbackProfile = ''
        profile "fallback" {
          output "*" enable
        }'';
    in
    mainProfile + "\n\n" + primaryProfile + (if primaryProfile != "" then "\n\n" else "") + fallbackProfile;
}
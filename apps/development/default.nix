{ pkgs, callPackage, mkApp, ... }:
let
  defaultConfig = {
    home = {
      home.packages = with pkgs; [
        python311
      ];
    };
  };
in
{
  default = mkApp defaultConfig;
  emacs = callPackage ./emacs {};
}

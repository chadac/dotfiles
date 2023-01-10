{ pkgs, callPackage, ... }:
let
  defaultConfig = {
    type = "app";
    home = {
      home.packages = with pkgs; [
        # python37
        # python38
        # python39
        # python310
        python311
      ];
    };
  };
in
{
  default = defaultConfig;
  emacs = callPackage ./emacs {};
}

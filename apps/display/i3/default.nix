{ config, ... }:
let
  theme = config.nix-config.theme;
in {
  nix-config.apps.i3 = {
    tags = [ "display" ];
    systems = [ "x86_64-linux" "aarch64-linux" ];
    home = (import ./home.nix theme);
    nixos = {
      services.displayManager.defaultSession = "none+i3";
      services.xserver = {
        windowManager.i3.enable = true;
      };
    };
  };
}

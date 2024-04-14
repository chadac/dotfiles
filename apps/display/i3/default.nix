{
  nix-config.apps.i3 = {
    tags = [ "display" ];
    home = import ./home.nix;
    nixos = {
      services.displayManager.defaultSession = "none+i3";
      services.xserver = {
        windowManager.i3.enable = true;
      };
    };
  };
}

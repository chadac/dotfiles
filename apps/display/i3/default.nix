{
  nix-config.apps.i3 = {
    tags = [ "display" ];
    home = import ./home.nix;
    nixos = {
      services.xserver = {
        displayManager.defaultSession = "none+i3";
        windowManager.i3.enable = true;
      };
    };
  };
}

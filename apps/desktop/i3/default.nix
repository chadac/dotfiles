{ pkgs }:
{
  type = "app";
  home = {
    xsession.windowManager.i3 = {
      enable = true;
      extraConfig = builtins.readFile ./i3config;
    };
  };
  nixos = {
    services.xserver = {
      displayManager.defaultSession = "none+i3";
    };
    windowManager.i3 = {
      enable = true;
    };
  };
}

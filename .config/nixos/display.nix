{ config, pkgs, lib, ... }:
{
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.setupCommands =
    ''
    ${pkgs.xorg.xrandr}/bin/xrandr \
      --output DVI-D-0 --off \
      --output HDMI-0 --mode 2560x1440 --pos 0x0 --rotate right \
      --output DP-0 --mode 2560x1440 --pos 1440x1120 --rotate normal \
      --output DP-1 --off \
      --output DP-2 --off \
      --output DP-3 --off \
      --output DP-4 --mode 2560x1440 --pos 4000x1120 --rotate normal \
      --output DP-5 --off
    '';
  services.xserver.displayManager.defaultSession = "none+i3";
  services.xserver.windowManager.i3.enable = true;
}

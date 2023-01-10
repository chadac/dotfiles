{ pkgs, lib }:
let
  mod = "Mod4";
  up = "l";
  down = "k";
  left = "j";
  right = "semicolon";
  i3StatusConfig = pkgs.writeText "i3status.conf" (builtins.readFile ./i3status.conf);
in
{
  type = "app";
  home = { config, ... }:
    {
    home.packages = with pkgs; [
      dmenu
      i3status
      i3lock
    ];
    xsession.windowManager.i3 = {
      enable = true;
      config = {
        modifier = mod;
        keybindings = lib.mkDefault {
          "${mod}+d" = ''exec "${pkgs.dmenu}/bin/dmenu_run"'';
          "${mod}+Shift+q" = "kill";
          "${mod}+Shift+t" = ''exec "${pkgs.i3lock}/bin/i3lock -p"'';

          "${mod}+${left}" = "focus left";
          "${mod}+${right}" = "focus right";
          "${mod}+${down}" = "focus down";
          "${mod}+${up}" = "focus up";

          "${mod}+Shift+${left}" = "move left";
          "${mod}+Shift+${right}" = "move right";
          "${mod}+Shift+${down}" = "move down";
          "${mod}+Shift+${up}" = "move up";

          "${mod}+s" = "layout stacking";
          "${mod}+w" = "layout tabbed";
          "${mod}+e" = "layout toggle split";
        };
      };
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

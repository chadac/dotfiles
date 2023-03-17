{ config, inputs, pkgs, lib, ... }:
let
  mod = "Mod4";
  up = "l";
  down = "k";
  left = "j";
  right = "semicolon";
  i3StatusConfig = pkgs.writeText "i3status.conf" (builtins.readFile ./i3status.conf);
  i3-nagbar = "${pkgs.i3}/bin/i3-nagbar";
in {
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
        "${mod}+d" = "exec '${pkgs.dmenu}/bin/dmenu_run'";
        "${mod}+Return" = "exec ${pkgs.xterm}/bin/xterm";
        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+t" = "exec '${pkgs.i3lock}/bin/i3lock -p'";
        "${mod}+Shift+e" = ''exec "${i3-nagbar} -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -b 'Yes, exit i3' 'i3-msg exit'"'';

        "${mod}+${left}" = "focus left";
        "${mod}+${right}" = "focus right";
        "${mod}+${down}" = "focus down";
        "${mod}+${up}" = "focus up";

        "${mod}+Shift+${left}" = "move left";
        "${mod}+Shift+${right}" = "move right";
        "${mod}+Shift+${down}" = "move down";
        "${mod}+Shift+${up}" = "move up";

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" =
          "move container to workspace number 1";
        "${mod}+Shift+2" =
          "move container to workspace number 2";
        "${mod}+Shift+3" =
          "move container to workspace number 3";
        "${mod}+Shift+4" =
          "move container to workspace number 4";
        "${mod}+Shift+5" =
          "move container to workspace number 5";
        "${mod}+Shift+6" =
          "move container to workspace number 6";
        "${mod}+Shift+7" =
          "move container to workspace number 7";
        "${mod}+Shift+8" =
          "move container to workspace number 8";
        "${mod}+Shift+9" =
          "move container to workspace number 9";
        "${mod}+Shift+0" =
          "move container to workspace number 10";

        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";
      };
    };
  };
}

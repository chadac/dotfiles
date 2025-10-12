theme: { host, config, inputs, pkgs, lib, ... }:
let
  inherit (builtins)
    concatLists
    hasAttr
    toString
  ;
  inherit (lib)
    mapAttrsToList
  ;

  mod = "Mod4";
  up = "l";
  down = "k";
  left = "j";
  right = "semicolon";
in {
  _file = __curPos.file;

  # Wayland equivalents of X11 packages
  home.packages = with pkgs; [
    wofi         # dmenu equivalent for Wayland
    swaylock     # i3lock equivalent for Wayland
    wl-clipboard # Wayland clipboard utilities
    grim         # Screenshot utility for Wayland
    slurp        # Selection utility for screenshots
    mako         # Notification daemon for Wayland (dunst equivalent)
  ];

  # Mako replaces dunst for Wayland
  services.mako = {
    enable = true;
    backgroundColor = "${theme.color8}F6";
    borderColor = "${theme.color4}F6";
    textColor = theme.foreground;
    defaultTimeout = 5000;
  };

  # Sway configuration - direct mapping from i3
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = mod;
      
      # Map workspaces to outputs same as i3
      workspaceOutputAssign = lib.mkIf (hasAttr "displays" host) (concatLists (
        mapAttrsToList
          (display: cfg: if(cfg.workspace != null) then
            [ { workspace = toString cfg.workspace; output = display; } ] else [ ])
          host.displays
      ));

      # Keybindings - exact mapping from i3
      keybindings = {
        "${mod}+d" = "exec ${pkgs.wofi}/bin/wofi --show drun";
        "${mod}+Return" = "exec ${lib.getExe config.programs.kitty.package}";
        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+t" = "exec ${pkgs.swaylock}/bin/swaylock";
        "${mod}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";

        # Focus movement - same keys as i3
        "${mod}+${left}" = "focus left";
        "${mod}+${right}" = "focus right";
        "${mod}+${down}" = "focus down";
        "${mod}+${up}" = "focus up";

        # Window movement - same keys as i3
        "${mod}+Shift+${left}" = "move left";
        "${mod}+Shift+${right}" = "move right";
        "${mod}+Shift+${down}" = "move down";
        "${mod}+Shift+${up}" = "move up";

        # Workspace switching - exact same as i3
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

        # Move containers to workspaces - exact same as i3
        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        # Layout management - same as i3
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+r" = "restart";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";

        # Screenshots (Wayland-specific addition)
        "Print" = "exec grim ~/screenshot.png";
        "Shift+Print" = "exec grim -g \"$(slurp)\" ~/screenshot.png";
      };

      # Colors - exact mapping from i3 with same theme variables
      colors = let
        defaults = {
          background = "${theme.color9}F6";
          border = "${theme.color4}F6";
          childBorder = "${theme.color8}F6";
          indicator = theme.color1;
          text = theme.foreground;
        };
      in {
        background = "${theme.color8}00";
        focused = defaults // {
          text = "#FFFFFF";
        };
        focusedInactive = defaults // {
          background = "${theme.color4}F6";
          text = "#000000";
        };
        unfocused = defaults // {
          background = "${theme.color0}F6";
          border = "#434C5EF6";
          text = "#C8CEF9";
        };
      };

      # Status bar - mapping from i3bar to waybar
      bars = [{
        command = "waybar";
        position = "top";
      }];

      # Output configuration will be handled by kanshi
      output = {};

      # Window rules - mapping from i3
      window.commands = [
        { criteria = { window_role = "alert"; }; command = "floating enable"; }
        { criteria = { window_role = "pop-up"; }; command = "floating enable"; }
        { criteria = { window_role = "bubble"; }; command = "floating enable"; }
        { criteria = { window_role = "task_dialog"; }; command = "floating enable"; }
        { criteria = { window_role = "Preferences"; }; command = "floating enable"; }
        { criteria = { window_type = "dialog"; }; command = "floating enable"; }
        { criteria = { window_type = "menu"; }; command = "floating enable"; }
      ];
    };
  };

  # Waybar replaces i3blocks/i3status
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        
        modules-left = [ "sway/workspaces" "sway/mode" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "custom/weather" "disk" "memory" "clock" ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };

        "custom/weather" = {
          exec = "curl 'https://wttr.in/Fort_Lauderdale?m&format=%c%t\\n'";
          interval = 3600;
        };

        disk = {
          format = "disk used: {used} free: {free}";
          path = "/";
          interval = 60;
        };

        memory = {
          format = "mem avail: {avail}M";
          interval = 1;
        };

        clock = {
          format = "{:%Y-%m-%d %H:%M:%S}";
          interval = 1;
        };
      };
    };

    style = ''
      * {
        font-family: monospace;
        font-size: 12px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: #2E3440E6;
        color: #D8DEE9;
        transition-property: background-color;
        transition-duration: .5s;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #D8DEE9;
        border-bottom: 3px solid transparent;
      }

      #workspaces button.focused {
        background-color: #5E81ACF6;
        border-bottom: 3px solid #434C5EE6;
      }

      #custom-weather, #disk, #memory, #clock {
        padding: 0 10px;
        margin: 0 4px;
        background-color: #434C5E;
        color: #D8DEE9;
      }
    '';
  };
}
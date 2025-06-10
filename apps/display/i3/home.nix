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


  i3 = pkgs.i3.overrideAttrs (final: prev: {
    patches = (prev.patches or []) ++ [
      ./i3-wintype-fix.patch
    ];
  });

  mod = "Mod4";
  up = "l";
  down = "k";
  left = "j";
  right = "semicolon";
  i3-nagbar = "${pkgs.i3}/bin/i3-nagbar";
in {
  _file = __curPos.file;

  home.packages = with pkgs; [
    dmenu
    i3lock
  ];

  services.dunst = {
    enable = true;
  };

  xsession.windowManager.i3 = {
    enable = true;
    package = i3;
    config = {
      modifier = mod;
      workspaceOutputAssign = lib.mkIf (hasAttr "displays" host) (concatLists (
        mapAttrsToList
          (display: cfg: if(cfg.workspace != null) then
            [ { workspace = toString cfg.workspace; output = display; } ] else [ ])
          host.displays
      ));

      keybindings = {
        "${mod}+d" = "exec '${pkgs.dmenu}/bin/dmenu_run'";
        "${mod}+Return" = "exec ${lib.getExe config.programs.kitty.package}";
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

      bars = let
        defaults = {
          background = "#5E81ACF6";
          border = "#434C5EE6";
          text = "#D8DEE9";
        };
      in [{
        command = "i3bar -t";
        statusCommand = "i3blocks";
        colors = {
          background = "#2E3440E6";
          focusedWorkspace = {
            background = "#5E81ACF6";
            border = "#434C5EE6";
            text = "#D8DEE9";
          };
          activeWorkspace = {
            background = "#4C566AE6";
            border = "#434C5EE6";
            text = "#D8DEE9";
          };
          inactiveWorkspace = {
            background = "#2E3440E6";
            border = "#434C5EE6";
            text = "#D8DEE9";
          };
          urgentWorkspace = {
            background = "#BF616AF6";
            border = "#434C5EE6";
            text = "#D8DEE9";
          };
        };
        fonts = {
          size = 12.0;
        };
        position = "top";
        trayOutput = "primary";
        trayPadding = 1;
        extraConfig = ''
          padding 0 6px 0 0
        '';
      }];
    };

    extraConfig = ''
      for_window [window_role="alert"]                        floating enable
      for_window [window_role="pop-up"]                       floating enable
      for_window [window_role="bubble"]                       floating enable
      for_window [window_role="task_dialog"]                  floating enable
      for_window [window_role="Preferences"]                  floating enable
      for_window [window_type="dialog"]                       floating enable
      for_window [window_type="menu"]                         floating enable
    '';
  };

  programs.i3status.enable = false;
  programs.i3blocks = {
    enable = true;
    bars = {
      config = {
        title = {
          full_text = "${host.name}";
        };
        weather = lib.hm.dag.entryAfter ["title"] {
          command = "curl 'https://wttr.in/Fort_Lauderdale?m&format=%c%t\\n'";
          interval = 3600;
        };
        disk = lib.hm.dag.entryAfter ["weather"] {
          command = "echo disk used: $(df / -h --output=used | cut -c 2- | tail -1) free: $(df / -h --output=avail | cut -c 2- | tail -1)";
          interval = 60;
        };
        memory = lib.hm.dag.entryAfter ["disk"] {
          command = ''
            cat /proc/meminfo | grep -E 'MemAvailable' | awk '{ print "mem avail: " int($2/1024) "M" }'
          '';
          interval = 1;
        };
        date = lib.hm.dag.entryAfter ["memory"] {
          command = "date";
          interval = 1;
        };
      };
    };
  };
}

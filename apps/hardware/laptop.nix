{
  nix-config.defaultTags.laptop = false;

  nix-config.homeApps = [{
    tags = [ "laptop" ];

    packages = [ "brightnessctl" ];
  }];

  nix-config.apps.laptop = {
    tags = [ "laptop" ];

    nixos = {
      powerManagement.powertop.enable = true;
      services.power-profiles-daemon.enable = true;
      services.thermald.enable = true;
    };

    home = { lib, ... }: {
      programs.i3blocks.bars.config.battery = lib.hm.dag.entryAfter [ "date" ] {
        command = ''
          cat /sys/class/power_supply/BAT0/capacity /sys/class/power_supply/BAT0/status | tr '\n' ' ' | awk '{ print "Bat: " $1 "%" }'
        '';
        interval = 20;
      };
    };
  };
}

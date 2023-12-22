# My primary laptop.
{
  type = "nixos";
  system = "x86_64-linux";

  username = "chadac";
  email = "chad@cacrawford.org";
  homeDirectory = "/home/chadac";

  allowUnfreePackages = [ "nvidia-x11" "nvidia-settings" ];

  nixosConfiguration = { ... }: {
    imports = [ ./nixos/hardware-configuration.nix ];
    networking.networkmanager.enable = true;
    services.logind = {
      powerKey = "hibernate";
      powerKeyLongPress = "poweroff";
    };
    programs.nm-applet.enable = true;
    hardware.pulseaudio.enable = true;
  };

  homeConfiguration = { pkgs, ... }: {
    home.packages = with pkgs; [ pavucontrol ];
  };

  getApps = apps: [ apps.full ];
}

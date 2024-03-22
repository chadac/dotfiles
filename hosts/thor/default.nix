# My primary laptop.
{
  nix-config.hosts.thor = {
    kind = "nixos";
    system = "x86_64-linux";

    username = "chadac";
    email = "chad@cacrawford.org";
    homeDirectory = "/home/chadac";

    tags = {
      laptop = true;
      gaming = true;
      nvidia = true;
    };

    nixpkgs.packages.unfree = [ "nvidia-x11" "nvidia-settings" ];

    nixos = {
      imports = [ ./nixos/hardware-configuration.nix ];
      networking.networkmanager.enable = true;
      services.logind = {
        powerKey = "hibernate";
        powerKeyLongPress = "poweroff";
      };
      programs.nm-applet.enable = true;
      hardware.pulseaudio.enable = true;
    };

    home = { pkgs, ... }: {
      home.packages = with pkgs; [ pavucontrol ];
    };
  };
}

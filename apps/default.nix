{ lib, ... }:
{
  imports = [
    # communication
    ./chat.nix

    # music & video
    ./entertainment.nix

    # general display
    ./display

    # development
    ./development

    # gaming
    ./gaming

    # hardware-specific configs
    ./hardware/desktop.nix
    ./hardware/laptop.nix

    # virtualization for kvms
    ./virt
  ];

  nix-config.defaultTags = {
    # if true, keep the deployment small
    minimal = false;

    # hardware-specific
    desktop = false;
    laptop = false;

    # categories
    chat = true;
    development = true;
    display = true;
    entertainment = true;
    gaming = false;
    virt = false;
  };

  nix-config.apps.init = {
    enable = true;
    nixos = { host, ... }: {
      system.stateVersion = "23.11";
      time.timeZone = "America/New_York";

      nix.settings = {
        substituters = [
          "https://cache.garnix.io"
        ];
        trusted-public-keys = [
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      };

      boot.loader = {
        efi = {
          canTouchEfiVariables = true;
        };
        systemd-boot.enable = true;
      };

      users.users.${host.username} = {
        extraGroups = [ "wheel" ];
      };
    };
    home = {
      home.stateVersion = "23.11";
    };
  };

  nix-config.apps.pipewire = {
    enable = true;
    nixos = { host, ... }: {
      services.pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
      };
    };
    home = { pkgs, ... }: {
      home.packages = with pkgs; [ pavucontrol ];
    };
  };

  nix-config.apps.pulseaudio = {
    enable = false;
    nixos = { host, ... }: {
      hardware.pulseaudio.enable = true;
      users.users.${host.username} = {
        extraGroups = [ "audio" ];
      };
    };
    home = { pkgs, ... }: {
      home.packages = with pkgs; [ pavucontrol ];
    };
  };
}

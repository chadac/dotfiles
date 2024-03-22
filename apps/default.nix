{ lib, ... }:
{
  imports = [
    # communication
    ./chat.nix

    # music & video
    ./entertainment.nix

    # general display
    ./display.nix
    ./display/i3
    ./display/Xresources
    ./display/wallpapers
    ./display/xserver
    ./display/xsession

    # development
    ./development.nix
    ./development/emacs
    ./development/git
    ./development/zsh

    # gaming
    ./gaming.nix
    ./gaming/emu

    # hardware-specific configs
    ./hardware/desktop.nix
    ./hardware/laptop.nix

    # virtualization for kvms
    ./virt.nix
    ./virt/libvirtd
  ];

  nix-config.defaultTags = {
    # if true, keep the deployment small
    minimal = false;
  };

  nix-config.apps.init = {
    enable = true;
    nixos = {
      system.stateVersion = "23.11";
    };
    home = {
      home.stateVersion = "23.05";
    };
  };
}

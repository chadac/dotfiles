{ host, pkgs, inputs, ...}:
let
  inherit (inputs) nixpkgs;
in
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  nix = {
    package = pkgs.nixFlakes;

    registry = {
      nixpkgs.flake = nixpkgs;
    };

    settings.trusted-users = [ "root" host.username ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.pkgs = pkgs;

  users.users.${host.username} = {
    isNormalUser = true;
    home = host.homeDirectory or "/home/${host.username}";
    description = host.username;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.layout = "us";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # disable default containers
  boot.enableContainers = false;
  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  services.openssh.enable = true;
  system.stateVersion = "22.11";
}

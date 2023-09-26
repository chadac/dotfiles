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
    registry = {
      nixpkgs.flake = nixpkgs;
    };

    settings = {
      trusted-users = [ "root" host.username ];
      experimental-features = [ "nix-command" "flakes" ];
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      allow-import-from-derivation = true
    '';
  };

  nixpkgs.pkgs = pkgs;

  users.users.${host.username} = {
    isNormalUser = true;
    home = host.homeDirectory or "/home/${host.username}";
    description = host.username;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.layout = "us";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.openssh.enable = true;
  system.stateVersion = "23.11";
}

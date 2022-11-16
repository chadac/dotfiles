# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      <home-manager/nixos>
      ./hardware-configuration.nix
      ./display.nix
      ./vfio.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
   };
  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/New_York";

  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.brlaser
    pkgs.brgenml1lpr
    pkgs.brgenml1cupswrapper
  ];

  manual.manpages.enable = false;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.displayManager.autoLogin.user = "chadac";

  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  boot.enableContainers = false;
  virtualisation = {
    podman = {
      enable = true;

      dockerCompat = true;
    };
  };

  # # Configuring zsh directly
  # programs.zsh = {
  #   enable = true;
  #   ohMyZsh.enable = true;
  #   loginShellInit =
  #   ''
  #   if [ -f $HOME/.zprofile ]; then
  #     source $HOME/.zprofile
  #   fi
  #   '';
  #   shellInit =
  #   ''
  #   if [ -f $HOME/.zshrc ]; then
  #     . $HOME/.zshrc
  #   fi
  #   '';
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  users.users.chadac = {
    isNormalUser = true;
    home = "/home/chadac";
    description = "Chad Crawford";
    extraGroups = [ "wheel" "networkmanager" "libvirtd" ];
    shell = pkgs.zsh;
  };

  # TODO: Eliminate this line
  nixpkgs.config.allowUnfree = true;

  # # List packages installed in system profile. To search, run:
  # # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   # Text Editors
  #   vim
  #   emacs
  #   # CLI Utilities
  #   git
  #   chezmoi
  #   wget
  #   asdf-vm
  #   binutils
  #   pciutils
  #   # Editing tools
  #   texlive.combined.scheme-full
  #   fontconfig
  #   # Build tools
  #   gcc
  #   gnumake
  #   # Desktop
  #   i3
  #   arandr
  #   ranger
  #   gimp
  #   evince
  #   blender
  #   # Web Browsing
  #   firefox
  #   thunderbird
  #   # Chat
  #   discord
  #   slack-dark
  #   signal-desktop
  #   # Entertainment
  #   spotify
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable";
}

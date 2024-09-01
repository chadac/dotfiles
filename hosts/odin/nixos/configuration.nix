{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./virt.nix
    ./display.nix
    ./docker.nix
    ./printing.nix

    # KVM Virtual Machine Configurations
    ./vms/workspace.nix
  ];

  time.timeZone = "America/New_York";

  hardware.nvidia.open = true;

  services.openssh.enable = true;
}

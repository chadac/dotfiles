{
  imports = [
    ./hardware-configuration.nix
    ./virt.nix
    ./display.nix

    # KVM Virtual Machine Configurations
    ./vms/workspace.nix
  ];
}

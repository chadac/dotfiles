{
  imports = [
    ./hardware-configuration.nix
    ./virt.nix

    # KVM Virtual Machine Configurations
    ./vms/workspace.nix
  ];
}

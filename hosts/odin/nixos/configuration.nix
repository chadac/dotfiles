{
  imports = [
    ./hardware-configuration.nix
    ./virt.nix
    ./display.nix
    ./docker.nix

    # KVM Virtual Machine Configurations
    ./vms/workspace.nix
  ];

  time.timeZone = "America/New_York";

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      efiSupport = true;
      device = "nodev";
    };
  };
}

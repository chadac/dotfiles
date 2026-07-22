{ host, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./virt.nix
    ./display.nix
    ./docker.nix
    ./k3s.nix
    ./printing.nix

    # KVM Virtual Machine Configurations
    ./vms/workspace.nix
  ];

  time.timeZone = "America/New_York";

  hardware.nvidia.open = host.tags.nvidia or false;

  services.openssh.enable = true;

  boot = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
    # kernelParams = [ "nouveau.config=NvGspRm=0" ];
  };
}

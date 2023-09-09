{ config, lib, pkgs, ... }:
{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/793af4fd-8927-420f-94a6-a4625d53d9c0";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DA6D-DDCA";
      fsType = "vfat";
    };

  fileSystems."/media/workspace" = {
    device = "/dev/disk/by-uuid/b5bf3248-07b7-4cf2-95b9-c02f5ec78eac";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/dev/nvme0n1p2";
    }
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}

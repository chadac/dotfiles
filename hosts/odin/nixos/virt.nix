# Based on https://www.reddit.com/r/VFIO/comments/p4kmxr/tips_for_single_gpu_passthrough_on_nixos/
# from /u/some_random_guy

# This is a config to enable VFIO for PCI Passthrough on
# KVM. Technically this also includse my KVM config itself.

{ host, config, pkgs, ... }:
{
  ## Need to enable VFIO
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
  boot.kernelModules = [ "kvm-intel" "vfio-pci" ];
  boot.extraModprobeConfig = "options vfio-pci ids=1002:67df,1002:aaf0";

  # Update libvirtd config to include passthrough for my host's devices.
  virtualisation.libvirtd = {
    qemu.ovmf.enable = true;
    qemu.verbatimConfig =
      ''
      user = "1000"
      cgroup_device_acl = [
        "/dev/input/by-id/usb-SteelSeries_SteelSeries_Sensei_Ten-if01-event-mouse",
        "/dev/input/by-id/usb-Kinesis_Advantage2_Keyboard_314159265359-if01-event-kbd",
        "/dev/null", "/dev/full", "/dev/zero", "/dev/random", "/dev/urandom",
        "/dev/ptmx", "/dev/kvm", "/dev/kqemu", "dev/rtc", "/dev/hpet",
        "/dev/sev"
      ]
      '';
  };
}

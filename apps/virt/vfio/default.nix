{ host, ... }:
let
  vfioGpus = builtins.concatStringsSep "," host.vfioGpuAddrs;
in
{
  nixos = {
    boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
    boot.kernelModules = [ "kvm-intel" "vfio-pci" ];
    boot.extraModprobeConfig = "options vfio-pci ${vfioGpus}";
  };
}

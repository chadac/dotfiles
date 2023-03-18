{ call, homePackage }:
{
  libvirtd = call ./libvirtd { };
  virt-manager = homePackage ./. "virt-manager";
}

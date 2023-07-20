{ call, mkApp, homePackage }:
{
  libvirtd = call ./libvirtd { };
  virt-manager = homePackage ./. "virt-manager";
  lxd = mkApp {
    src = ./.;
    nixos = { ... }: {
      virtualisation.lxc = {
        systemConfig = ''
          lxc.cgroup2.devices.allow: c 189:* rwm
        '';
      };
      virtualisation.lxd.enable = true;
    };
  };
}

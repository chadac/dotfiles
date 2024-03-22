let
  tags = [ "virt" ];
in {
  nix-config.defaultTags.virt = false;

  nix-config.homeApps = [{
    inherit tags;
    packages = [ "virt-manager" ];
  }];

  nix-config.apps = {
    lxd = {
      inherit tags;
      nixos = {
        virtualisation.lxc = {
          systemConfig = ''
            lxc.cgroup2.devices.allow: c 189:* rwm
          '';
        };
        virtualisation.lxd.enable = true;
      };
    };
  };
}

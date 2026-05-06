let
  tags = [ "virt" ];
in {
  imports = [
    ./libvirtd
  ];

  nix-config.homeApps = [{
    inherit tags;
    systems = [ "x86_64-linux" "aarch64-linux" ];
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
      };
    };
  };
}

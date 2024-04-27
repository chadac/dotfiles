{
  nix-config.defaultTags.laptop = false;

  nix-config.homeApps = [{
    tags = [ "laptop" ];

    packages = [ "brightnessctl" ];
  }];

  nix-config.apps.laptop = {
    tags = [ "laptop" ];

    nixos = {
      powerManagement.powertop.enable = true;
      services.power-profiles-daemon.enable = true;
      services.thermald.enable = true;
    };
  };
}

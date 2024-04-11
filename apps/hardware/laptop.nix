{
  nix-config.defaultTags.laptop = false;

  nix-config.homeApps = [{
    tags = [ "laptop" ];

    packages = [ "brightnessctl" ];
  }];

  nix-config.apps.laptop = {
  };
}

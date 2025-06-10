{
  nix-config.defaultTags.bluetooth = false;

  nix-config.apps.bluetooth = {
    tags = [ "bluetooth" ];
    nixos = {
      hardware.bluetooth = {
        enable = true;
        settings = {
          General = {
            ControllerMode = "bredr";
          };
        };
        powerOnBoot = true;
      };
    };
  };
}

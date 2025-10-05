{ inputs, ... }: {
  nix-config.apps.determinate-nix = {
    enable = true;
    nixos = { pkgs, ... }: {
      imports = [
        inputs.determinate.nixosModules.default
      ];
    };
  };
}

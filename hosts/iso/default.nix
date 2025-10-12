let
  isoHost = system: { inputs, ... }: {
    nix-config.hosts."iso-${system}" = {
      kind = "nixos";
      inherit system;

      username = "nixos";
      email = "chad@cacrawford.org";
      homeDirectory = "/home/nixos";

      tags = {
        nvidia = true;
        bluetooth = true;
      };
      nixos = { pkgs, ... }: {
        imports = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];
        environment = {
          etc.nixos-config.source = ../../.;

          systemPackages = with pkgs; [
            util-linux
            parted
          ];
        };
      };
    };
  };
  systems = ["x86_64-linux" "aarch64-linux"];
in {
  imports = map isoHost systems;
}

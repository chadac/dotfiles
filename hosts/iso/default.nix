let
  isoHost = system: { inputs, ... }: {
    nix-config.hosts."iso-${system}" = {
      kind = "nixos";
      inherit system;

      username = "chadac";
      email = "chad@cacrawford.org";
      homeDirectory = "/home/chadac";

      tags = {
        minimal = true;
        chat = false;
        display = false;
        entertainment = false;
      };
      nixos = { pkgs, ... }: {
        imports = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];
        environment.systemPackages = with pkgs; [
          util-linux
          parted
        ];
      };
    };
  };
  systems = ["x86_64-linux" "aarch64-linux"];
in {
  imports = map isoHost systems;
}

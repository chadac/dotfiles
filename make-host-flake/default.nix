{
  host,
  apps,
  ...
}@inputs:
let
  pkgs = import ./nixpkgs.nix inputs;
  args = { inherit pkgs; inherit host; inherit apps; };
in
{
  imports = [
    (import ./home-manager.nix args)
    (import ./nixos.nix args)
  ];
}

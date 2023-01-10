{
  nixpkgs,
  emacs-overlay,
  ...
}@inputs:
host:
let
  pkgs = import nixpkgs {
    inherit (host) system;
    overlays = [ (import emacs-overlay) ];
  };
  inherit (pkgs) lib stdenv;
  callPackage = lib.callPackageWith (pkgs // {
    inherit pkgs;
    inherit lib;
    inherit stdenv;
    inherit apps;
    inherit host;
    inherit hostApps;
    inherit callPackage;
  } // inputs);
  checkImport = property: file: if (builtins.hasAttr property host) then (callPackage file {}) else null;
  apps = callPackage ../apps { };
  hostApps = host.getApps apps;
in {
  nixosConfiguration = checkImport "nixosConfiguration" ./nixos.nix;
  homeConfiguration = checkImport "homeConfiguration" ./home-manager.nix;
  devShell = callPackage ./dev-shell.nix {};
}

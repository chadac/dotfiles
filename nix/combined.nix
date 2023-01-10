{
  nixpkgs,
  emacs-overlay,
  ...
}@inputs:
host:
let
  inherit (nixpkgs) lib;
  pkgs = import nixpkgs {
    inherit (host) system;
    overlays = [ (import emacs-overlay) ];
    config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "slack"
        "spotify"
        "discord"
      ];
  };
  buildInputs = pkgs // {
    inherit pkgs;
    inherit (pkgs) lib stdenv;
    inherit apps;
    inherit host;
    inherit hostApps;
    inherit callPackage;
    inherit buildInputs;
  } // inputs;
  callPackage = lib.callPackageWith buildInputs;
  checkImport = property: file: if (builtins.hasAttr property host) then (callPackage file {}) else null;
  apps = callPackage ../apps { };
  hostApps = host.getApps apps;
in {
  nixosConfiguration = checkImport "nixosConfiguration" ./nixos.nix;
  homeConfiguration = checkImport "homeConfiguration" ./home-manager.nix;
  devShell = callPackage ./dev-shell.nix {};
}

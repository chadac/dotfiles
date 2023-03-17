{ host, nixpkgs, apps, ... }:
let
  inherit (nixpkgs) lib;
in
import nixpkgs {
  inherit (host) system;
  overlays = apps.overlays;
  config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) ([
      "slack"
      "spotify"
      "discord"
    ] ++ (host.allowUnfreePackages or []));
}

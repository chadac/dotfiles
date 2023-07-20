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
      "steam"
      "steam-original"
      "steam-runtime"
      "steam-run"
    ] ++ (host.allowUnfreePackages or []));
}

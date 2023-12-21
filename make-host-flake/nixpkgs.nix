{ host, nixpkgs, apps, ... }:
let
  inherit (nixpkgs) lib;
in
import nixpkgs {
  inherit (host) system;
  overlays = apps.overlays;
  config.allowUnfreePredicate = pkg: (
    (lib.hasPrefix "libretro-" (lib.getName pkg)) ||
    (builtins.elem (lib.getName pkg) ([
      "discord"
      "libretro-fbalpha2012"
      "libretro-fbneo"
      "minecraft"
      "slack"
      "spotify"
      "steam"
      "steam-original"
      "steam-runtime"
      "steam-run"
    ] ++ (host.allowUnfreePackages or [])))
  );
}

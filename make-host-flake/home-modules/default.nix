{ host, apps, ... }:
[
  ./global.nix
  (host.homeConfiguration or {})
] ++ apps.homeModules

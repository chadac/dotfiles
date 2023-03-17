{ host, apps, ... }:
[
  (import ./global.nix)
  (host.homeConfiguration or {})
] ++ apps.homeModules

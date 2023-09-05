{ host, apps, ... }:
[
  ./global.nix
  ./home.nix
  (host.nixosConfiguration or {})
] ++ apps.nixosModules

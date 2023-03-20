let
  hosts = {
    odin = import ./odin;
    forseti = import ./forseti;
  };
  genHostConfig = hostname: config: config // { inherit hostname; };
in builtins.mapAttrs genHostConfig hosts

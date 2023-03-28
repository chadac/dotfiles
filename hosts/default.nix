let
  hosts = {
    odin = import ./odin;
    forseti = import ./forseti;
    baldur = import ./baldur;
  };
  genHostConfig = hostname: config: config // { inherit hostname; };
in builtins.mapAttrs genHostConfig hosts

let
  inherit (builtins) listToAttrs;
  isoImages = listToAttrs (
    map
      (system: { name = "iso-${system}"; value = import ./iso system; })
      [ "x86_64-linux" "aarch64-linux" ]
  );

  hosts = {
    odin = import ./odin;
    thor = import ./thor;
    forseti = import ./forseti;
    baldur = import ./baldur;
  } // isoImages;

  genHostConfig = hostname: config: config // { inherit hostname; };
in builtins.mapAttrs genHostConfig hosts

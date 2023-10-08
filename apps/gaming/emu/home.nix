{ pkgs, config, ... }:
let
  inherit (builtins) readFile;
in
{
  home = {
    packages = with pkgs; [
      emulationstation
      retroarchFull
    ];

    file = {
      "${config.home.homeDirectory}/.emulationstation/es_systems.cfg" = {
        source = ./es_systems.cfg;
      };
    };
  };
}

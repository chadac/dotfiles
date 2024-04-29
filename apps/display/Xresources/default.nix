{ config, ... }:
let
  theme = config.nix-config.theme;
in {
  nix-config.apps.Xresources = {
    tags = [ "display" ];
    home = { config, pkgs, ... }: let
      dest = "${config.home.homeDirectory}/.Xresources";
      imports = [
        ./.Xresources.d/xterm
      ];
      Xresources = import ./Xresources.nix theme imports;
    in {
      # save to a local file instead
      home.file = {
        "${dest}" = { text = Xresources; };
      };
      xsession.profileExtra = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge ${dest}
      '';
    };
  };
}

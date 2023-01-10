{ pkgs, mkApp }:
let
  xpath = pkgs.copyPathToStore ./.;
in
mkApp {
  home = {
    xsession.profileExtra = ''
      ${pkgs.xorg.xrdb}/bin/xrdb -merge ${xpath}/.Xresources
    '';
  };
}

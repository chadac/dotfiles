{ pkgs }:
let
  xpath = pkgs.copyPathToStore ./.;
in
{
  type = "app";
  home = {
    xsession.profileExtra = ''
      ${pkgs.xorg.xrdb}/bin/xrdb -merge ${xpath}/.Xresources
    '';
  };
}

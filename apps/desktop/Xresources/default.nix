{ pkgs }:
let
  xpath = ./.Xresources;
in
{
  type = "app";
  home = {
    xsession.profileExtra = ''
      ${pkgs.xorg.xrdb}/bin/xrdb -merge ${xpath}
    '';
  };
}

{ mkApp }:
mkApp {
  src = ./.;
  home = { pkgs, ... }:
    let
      xpath = pkgs.copyPathToStore ./.;
    in
      {
        xsession.profileExtra = ''
          ${pkgs.xorg.xrdb}/bin/xrdb -merge ${xpath}/.Xresources
        '';
      };
}

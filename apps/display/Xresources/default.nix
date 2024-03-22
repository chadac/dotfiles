{
  nix-config.apps.Xresources = {
    tags = [ "display" ];
    home = { pkgs, lib, ... }:
      let
        inherit (pkgs) stdenv;
        xpath = stdenv.mkDerivation {
          name = "xpath";
          src = ./.;
          patchPhase = ''
            substituteInPlace .Xresources \
              --replace '.Xresources.d' "$out/.Xresources.d"
          '';
          buildPhase = ''true'';
          installPhase = ''
            mkdir -p $out
            cp -ra . $out/
          '';
        };
      in
        {
          xsession.profileExtra = ''
            ${pkgs.xorg.xrdb}/bin/xrdb -merge ${xpath}/.Xresources
          '';
        };
  };
}

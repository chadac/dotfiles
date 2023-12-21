{ mkApp }:
mkApp {
  src = ./.;
  home = { pkgs, lib, ... }:
    let
      inherit (pkgs) stdenv;
      xpath = stdenv.mkDerivation {
        name = "xpath";
        src = ./.;
        # unpackPhase = ''
        #   mkdir source
        #   cp -a $src source/
        #   cd source
        # '';
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
      #pkgs.copyPathToStore ./.;
    in
      {
        xsession.profileExtra = ''
          ${pkgs.xorg.xrdb}/bin/xrdb -merge ${xpath}/.Xresources
        '';
      };
}

{
  nix-config.apps.Xresources = {
    tags = [ "display" ];
    home = { pkgs, lib, config, ... }:
      let
        inherit (pkgs) stdenv;
        xpath = stdenv.mkDerivation {
          pname = "xpath";
          version = "1.0.0";
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
          home.file = {
            "${config.home.homeDirectory}/.Xresources" = { source = ./.Xresources; };
            "${config.home.homeDirectory}/.Xresources.d" = {
              source = ./.Xresources.d;
              recursive = true;
            };
          };
          xsession.profileExtra = ''
            ${pkgs.xorg.xrdb}/bin/xrdb -merge ${config.home.homeDirectory}/.Xresources
          '';
        };
  };
}

{ pkgs, python, ... }:
let
  python-env = python.withPackages(p: with p; [
    pipx
  ]);
in
pkgs.stdenv.mkDerivation {
  name = "poetry";
  buildInputs = [ python-env ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${python-env}/bin/pipx $out/bin/pipx
  '';
}

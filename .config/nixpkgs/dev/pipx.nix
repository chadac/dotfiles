{ pkgs, ... }:
let
  python-env = pkgs.python310.withPackages(p: with p; [
    poetry
  ]);
in
pkgs.stdenv.mkDerivation {
  name = "poetry";
  buildInputs = [ python-env ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${python-env}/bin/poetry $out/bin/poetry
  '';
}

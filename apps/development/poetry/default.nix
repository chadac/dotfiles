{ mkApp }:
mkApp {
  src = ./.;
  home = { pkgs, ... }:
    let
      poetry = pkgs.python311.withPackages(p: with p; [
        poetry
      ]);
    in {
      home.packages = [ poetry ];
    };
}

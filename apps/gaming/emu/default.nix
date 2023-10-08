{ mkApp, ... }: mkApp {
  src = ./.;
  home = import ./home.nix;
}

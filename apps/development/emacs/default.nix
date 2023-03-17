{ mkApp, emacs-overlay }:
mkApp {
  src = ./.;
  overlay = emacs-overlay.overlay;
  home = import ./home.nix;
}

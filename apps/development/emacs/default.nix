{ mkApp, emacs-overlay }:
mkApp {
  src = ./.;
  # Use https://github.com/nix-community/emacs-overlay
  overlay = emacs-overlay.overlay;
  home = import ./home.nix;
}

{ lib, inputs, ... }:
{
  nix-config.apps.emacs = {
    tags = [ "development" ];
    nixpkgs = { host, ... }: {
      params.overlays = [
        inputs.emacs-overlay.overlay
      ];
    };
    nixos = { pkgs, ... }: {
      # Cozette bitmap font used by the default face in init.local.el.
      # Installed here so every host with emacs (including the workspace
      # VMs) gets the font, not just hosts that enable kitty.
      fonts.packages = [ pkgs.cozette ];
    };
    home = import ./home.nix;
  };
}

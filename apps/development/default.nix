{ call, mkApp, rtx, poetry2nix, ... }:
{
  python = mkApp {
    src = ./.;
    home = { pkgs, ... }: {
      home.packages = [ pkgs.python311 ];
      programs.git.ignores = [
        # python
        "__pycache__/"
        "*.pyc"
        ".dmypy.json"
      ];
    };
  };

  # rtx for language runtime version management
  rtx = mkApp {
    src = ./.;
    overlay = rtx.overlay;
    home = { pkgs, ... }: {
      home.packages = [ pkgs.rtx ];
    };
  };

  poetry2nix = mkApp {
    src = ./.;
    overlay = poetry2nix.overlay;
  };

  emacs = call ./emacs { };

  podman = call ./podman.nix { };
}

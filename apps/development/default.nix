{ call, mkApp, rtx, ... }:
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

  emacs = call ./emacs { };

  podman = call ./podman.nix { };
}

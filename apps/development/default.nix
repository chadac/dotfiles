{ call, mkApp, homePackage, fh, rtx, poetry2nix, ... }:
{
  python = mkApp {
    src = ./.;
    home = { pkgs, ... }: {
      home.packages = with pkgs; [
        python311
        poetry
        black
        isort
        pylint
      ];
      programs.git.ignores = [
        # python
        "__pycache__/"
        "*.pyc"
        ".dmypy.json"
      ];
    };
  };

  # GitHub CLI
  gh = homePackage ./. "gh";

  # FlakeHub CLI
  fh = mkApp {
    src = ./.;
    overlay = fh.overlays.default;
    home = { pkgs, ... }: {
      home.packages = [ pkgs.fh ];
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

  # poetry2nix = mkApp {
  #   src = ./.;
  #   overlay = poetry2nix.overlay;
  # };

  emacs = call ./emacs { };

  podman = call ./podman.nix { };

  nix = let
    nixVersion = "nix_2_17";
  in mkApp {
    src = ./.;
    nixos = { pkgs, ... }: {
      nix.package = pkgs.nixVersions.${nixVersion};
    };
    home = { pkgs, ... }: {
      home.packages = with pkgs; [ nixVersions.${nixVersion} ];
    };
  };

  essential = mkApp {
    src = ./.;
    home = { pkgs, ... }: {
      home.packages = with pkgs; [
        awscli
        gnumake
      ];
    };
  };
}

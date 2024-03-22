{ ... }:
let
  tags = [ "development" ];
in {
  nix-config.defaultTags.development = true;

  nix-config.homeApps = [
    {
      inherit tags;
      packages = [
        "unzip"
        "hyperfine"
        "dig"
        "jq"
        "lm_sensors"
        "pciutils"
        "gnumake"
        "ripgrep"
        "vim"
      ];
    }
    {
      inherit tags;
      disableTags = [ "minimal" ];
      packages = [
        "awscli"
        "gh"
      ];
    }
  ];

  nix-config.apps = {
    nix-ld = {
      inherit tags;
      nixos = {
        programs.nix-ld.enable = true;
      };
    };

    python = {
      inherit tags;
      home = { pkgs, ... }: {
        home.packages = with pkgs; [
          python311
          poetry
          black
          isort
          pylint
          pyright
        ];
        programs.git.ignores = [
          "__pycache__/"
          "*.pyc"
          ".dmypy.json"
        ];
      };
    };

    fh = {
      inherit tags;
      nixpkgs = { inputs, ... }: {
        params.overlays = [ inputs.fh.overlays.default ];
      };
      home = { pkgs, ... }: {
        home.packages = [ pkgs.fh ];
      };
    };

    rtx = {
      inherit tags;
      nixpkgs = { inputs, ... }: {
        params.overlays = [ inputs.rtx.overlay ];
      };
      home = { pkgs, ... }: {
        home.packages = [ pkgs.rtx ];
      };
    };

    nix = let
      nixVersion = "nix_2_19";
    in {
      inherit tags;
      nixos = { pkgs, ... }: {
        nix.package = pkgs.nixVersions.${nixVersion};
      };
      home = { pkgs, ... }: {
        home.packages = [ pkgs.nixVersions.${nixVersion} ];
      };
    };
  };
}

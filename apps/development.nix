{ ... }:
let
  tags = [ "development" ];
in {
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
    podman = {
      inherit tags;
      nixos = { pkgs, ... }: {
        virtualision.containers.enable = true;

        virtualisation.podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true;
        };

        environment.systemPackages = with pkgs; [
          dive
          podman-tui
          podman-compose
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

    kubernetes = {
      inherit tags;
      home = { pkgs, ... }: {
        home.packages = with pkgs; [
          kubectl
          k9s
        ];
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

    nix-ld = {
      inherit tags;
      nixos = {
        programs.nix-ld.enable = true;
      };
    };
  };
}

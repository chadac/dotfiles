{ ... }:
let
  tags = [ "development" ];
in {
  # nix-config.systemApps = [{
  #   inherit tags;
  #   packages = [
  #   ];
  # }];
  imports = [
    ./emacs
    ./git
    ./zsh
  ];

  nix-config.homeApps = [
    {
      inherit tags;
      packages = [
        "busybox"
        "dig"
        "gnumake"
        "jq"
        "lm_sensors"
        "pciutils"
        "unzip"
        "vim"
        "zip"

        "unzip"
        "hyperfine"
        "ripgrep"
        "opentofu"
      ];
    }
    {
      inherit tags;
      disableTags = [ "minimal" ];
      packages = [
        "awscli2"
        "gh"
      ];
    }
  ];

  nix-config.apps = {
    podman = {
      inherit tags;
      nixos = { pkgs, ... }: {
        virtualisation.containers.enable = true;

        virtualisation.podman = {
          enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
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
  };
}

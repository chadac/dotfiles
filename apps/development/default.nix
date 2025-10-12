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
      systems = [ "x86_64-linux" "aarch64-linux" ];
      packages = [
        "psmisc"
        "lm_sensors"
        "awscli2"
        "nh"
      ];
    }
    {
      inherit tags;
      packages = [
        "dig"
        "gnumake"
        "jq"
        "pciutils"
        "unzip"
        "vim"
        "zip"

        "unzip"
        "hyperfine"
        "ripgrep"
        "opentofu"
        "terraform"
        "terraform-ls"
      ];
    }
    {
      inherit tags;
      disableTags = [ "minimal" ];
      packages = [
        # temp: remove since it has mismatched dependencies
        # "awscli2"
        "gh"
      ];
    }
  ];

  nix-config.apps = {
    terraform = {
      inherit tags;
      nixpkgs.packages.unfree = [ "terraform" ];
    };

    direnv = {
      inherit tags;
      home = {
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        programs.git.ignores = [
          ".envrc"
          ".direnv/"
        ];
      };
    };

    golang = {
      inherit tags;
      home = { pkgs, ... }: {
        home.packages = with pkgs; [ gopls ];
      };
    };

    latex = {
      inherit tags;
      nixos = {
        # evince used for viewing/auctex
        programs.evince.enable = true;
      };
      home = { pkgs, ... }: let
        # usually I already have latex set up... this is barebones
        latex = (pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-basic
          ;
        });
      in {
        home.packages = [ latex ];
      };
    };

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
      systems = [ "x86_64-linux" "aarch64-linux" ];
      nixpkgs = { inputs, ... }: {
        params.overlays = [ inputs.fh.overlays.default ];
      };
      home = { pkgs, ... }: {
        home.packages = [ pkgs.fh ];
      };
    };

    kitty = {
      inherit tags;
      nixos = { pkgs, ... }: {
        fonts.packages = with pkgs; [
          courier-unicode
        ];
      };
      home = { pkgs, lib, ... }: {
        programs.kitty = {
          enable = true;
          themeFile = "Nord";
          font = lib.mkIf pkgs.stdenv.isLinux {
            package = pkgs.courier-unicode;
            name = "Courier";
          };
          settings = {
            background_opacity = "0.95";
            enable_audio_bell = "no";
          };
        };
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
      nixVersion = "latest";
    in {
      enable = false;
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
      home = { pkgs, ... }: let
        python-env = pkgs.python313.withPackages (p: with p; [
          rope
          flake8
          isort
          black
        ]);
      in {
        home.packages = with pkgs; [
          python-env
          poetry
          pyright
        ];
        programs.git.ignores = [
          "__pycache__/"
          "*.pyc"
          ".dmypy.json"
        ];
      };
    };

    rust = {
      inherit tags;
      home = { pkgs, ... }: {
        home.packages = with pkgs; [
          rust-analyzer
        ];
      };
    };

    kotlin = {
      inherit tags;
      home = { pkgs, ... }: {
        home.packages = with pkgs; [
          kotlin-language-server
        ];
      };
    };

    mise = {
      inherit tags;
      # nixpkgs = { inputs, ... }: {
      #   params.overlays = [ inputs.mise.overlay ];
      # };
      home = { pkgs, ... }: {
        home.packages = [ pkgs.mise ];

        # programs.zsh.profileExtra = ''
        #   eval "$(mise activate zsh)"
        # '';
      };
    };

    gnome-keyring = {
      inherit tags;
      nixos = {
        security.pam.services.lightdm.enableGnomeKeyring = true;
        services.gnome.gnome-keyring.enable = true;
      };
    };
  };
}

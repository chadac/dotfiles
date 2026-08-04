{
  description = "@chadac's dotfiles";

  nixConfig = {
    extra-trusted-substituters = [
      "https://chadac-dotfiles.cachix.org"
      "https://install.determinate.systems"
    ];
    extra-trusted-public-keys = [
      "chadac-dotfiles.cachix.org-1:X6SN8xFOL7yHXvmFHDfYLAQy0U4E6qgq+2wlOLwTc1c="
      "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
    ];
  };

  inputs = {
    # use unstable for latest features
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # flakehub cli
    fh.url = "https://api.flakehub.com/f/DeterminateSystems/fh/0.1.*.tar.gz";

    flake-utils.url = "https://api.flakehub.com/f/numtide/flake-utils/0.1.*.tar.gz";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-config-modules.url = "github:chadac/nix-config-modules";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Determinate Nix
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## Applications

    # dt - duct tape for your pipes
    dt = {
      url = "github:so-dang-cool/dt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # emacs - latest versions
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
    };

    # nixcord - declarative Vencord-patched Discord
    nixcord = {
      url = "github:4evy/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # for building poetry packages
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    # for managing dev environments
    mise = {
      url = "github:jdx/mise";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    ## Assets

    # zsh-256color is useful to be cutting-edge
    zsh-256color = {
      url = "github:chrissicool/zsh-256color";
      flake = false;
    };
  };

  outputs = { flake-parts, ...}@inputs: let
    flakeModule = {
      imports = [
        inputs.nix-config-modules.flakeModule
        ./hosts
        ./apps
        ./tests.nix

        ./themes
        ./themes/nord.nix
      ]
      # map iso images to packages for simplicity
      ++ (map (import ./iso.nix) ["x86_64-linux" "aarch64-linux"]);

      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      perSystem = { pkgs, ... }: {
        devShells.default = pkgs.mkShell { packages = with pkgs; [ just ]; };
      };
    };
  in
    (flake-parts.lib.mkFlake { inherit inputs; } flakeModule) //
    { inherit flakeModule; }
  ;
}

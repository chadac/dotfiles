{
  description = "@chadac's dotfiles";

  nixConfig = {
    extra-trusted-substituters = [
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
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
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      # url = "https://api.flakehub.com/f/nix-community/home-manager/0.2405.*.tar.gz";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dt = {
      url = "github:so-dang-cool/dt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Applications
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    mise = {
      url = "github:jdx/mise";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # Assets to auto-update
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

        ./themes
        ./themes/nord.nix
      ]
      # map iso images to packages for simplicity
      ++ (map (import ./iso.nix) ["x86_64-linux" "aarch64-linux"]);

      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    };
  in
    (flake-parts.lib.mkFlake { inherit inputs; } flakeModule) //
    { inherit flakeModule; }
  ;
}

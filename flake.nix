{
  description = "@chadac's dotfiles";

  inputs = {
    nixpkgs.url = "https://api.flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";

    # # flakehub cli
    fh.url = "https://api.flakehub.com/f/DeterminateSystems/fh/0.1.*.tar.gz";

    flake-utils.url = "https://api.flakehub.com/f/numtide/flake-utils/0.1.*.tar.gz";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "https://api.flakehub.com/f/nix-community/home-manager/0.1.*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Applications
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.flake-utils.follows = "flake-utils";
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    rtx = {
      url = "github:jdxcode/rtx";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # Assets to auto-update
    zsh-256color = {
      url = "github:chrissicool/zsh-256color";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-parts, ...}@inputs:
    let
      inherit (nixpkgs) lib;
      inherit (builtins) attrValues getAttr removeAttrs map;
      hosts = lib.attrValues (import ./hosts);
      systems = lib.unique (map (getAttr "system") hosts);
      modules = import ./flake-parts-modules;
      flakeInputs = removeAttrs inputs ["self" "flake-parts" "flake-utils"];
      makeHostFlake = import ./make-host-flake;
      hostFlakes = map (host:
        let
          apps = import ./apps hostInputs;
          hostInputs = flakeInputs // { inherit host; inherit apps; };
        in makeHostFlake hostInputs
      ) hosts;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ modules ] ++ hostFlakes;
      inherit systems;

      # TODO: This `pkgs` definitely doesn't have my overrides. Need
      # to migrate this to `./make-host-config`.
      perSystem = { system, pkgs, ... }: {
        packages = {
          home-manager = home-manager.defaultPackage.${system};
          nixos-rebuild = pkgs.nixos-rebuild;
          default = pkgs.writeShellScriptBin "dummy" ''echo "Hello World!"'';
        };
      };

      flake = {
        lib = {
          inherit hosts;
          inherit makeHostFlake;
        };
      };
    };
}

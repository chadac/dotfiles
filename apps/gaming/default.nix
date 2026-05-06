let
  tags = [ "gaming" ];
in {
  imports = [
    ./emu
  ];

  nix-config.apps = {
    steam = {
      inherit tags;
      nixpkgs.packages.unfree = [
        "steam"
        "steam-unwrapped"
        "steam-original"
        "steam-run"
      ];
      nixpkgs.packages.insecure = [
        "mbedtls"
      ];
      nixos = {
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };
      };
    };

    lutris = {
      inherit tags;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      # TODO: remove overlay once nixpkgs#514113 is resolved (PR #515956)
      nixpkgs.params.overlays = [(_: prev: {
        openldap = prev.openldap.overrideAttrs (old: {
          preCheck = (old.preCheck or "") + ''
            # syncreplication timing-sensitive tests, fail on slow/sandboxed builders
            rm -f tests/scripts/test*-sync*
          '';
        });
      })];
      home = { pkgs, ... }: {
        home.packages = with pkgs; [ lutris ];
      };
    };

    gamemode = {
      inherit tags;
      nixos.programs.gamemode.enable = true;
    };
  };
}

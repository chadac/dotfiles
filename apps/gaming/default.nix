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

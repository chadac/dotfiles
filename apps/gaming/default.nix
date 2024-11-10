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

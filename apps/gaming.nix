let
  tags = [ "gaming" ];
in {
  nix-config.defaultTags.gaming = false;

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
    };
  };
}

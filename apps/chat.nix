let
  tags = [ "chat" ];
in {
  nix-config.homeApps = [{
    inherit tags;
    packages = [ "discord" "element-desktop" "slack" "signal-desktop" ];
  }];

  nix-config.apps = {
    slack = {
      nixpkgs.packages.unfree = [ "slack" ];
    };
    discord = {
      nixpkgs.packages.unfree = [ "discord" ];
    };
  };

  nix-config.defaultTags.chat = true;
}

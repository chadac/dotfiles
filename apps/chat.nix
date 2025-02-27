let
  tags = [ "chat" ];
in {
  nix-config.homeApps = [
    {
      inherit tags;
      packages = [ "discord" "element-desktop" "slack" ];
    }
    {
      inherit tags;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      packages = [ "signal-desktop" ];
    }
  ];

  nix-config.apps = {
    slack = {
      nixpkgs.packages.unfree = [ "slack" ];
    };
    discord = {
      nixpkgs.packages.unfree = [ "discord" ];
    };
  };
}

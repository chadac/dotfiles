let
  tags = [ "chat" ];
in {
  nix-config.homeApps = [
    {
      inherit tags;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      packages = [ "element-desktop" ];
    }
    {
      inherit tags;
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      packages = [ "discord" ];
    }
    {
      inherit tags;
      systems = [ "x86_64-linux" "x86_64-darwin" ];
      packages = [ "slack" ];
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

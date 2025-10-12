{ ... }:
let
  tags = [ "entertainment" ];
in
{
  nix-config = {
    homeApps = [
      {
        inherit tags;
        systems = [ "x86_64-linux" ];
        packages = [
          "tidal-hifi"
        ];
      }
      {
        inherit tags;
        systems = [ "x86_64-linux" "aarch64-linux" ];
        packages = [
          "vlc"
        ];
      }
      {
        inherit tags;
        systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
        disableTags = [ "minimal" ];
        packages = [
          "spotify"
        ];
      }
    ];

    apps = {
      spotify = {
        nixpkgs.packages.unfree = [ "spotify" ];
      };
      tidal-hifi = {
        nixpkgs.packages.unfree = [ "castlabs-electron" ];
      };
    };
  };
}

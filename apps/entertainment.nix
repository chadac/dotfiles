{ ... }:
let
  tags = [ "entertainment" ];
in
{
  nix-config = {
    homeApps = [
      {
        inherit tags;
        systems = [ "x86_64-linux" "aarch64-linux" ];
        packages = [
          "tidal-hifi"
          "vlc"
        ];
      }
      {
        inherit tags;
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

{ ... }:
let
  tags = [ "entertainment" ];
in
{
  nix-config = {
    defaultTags.entertainment = true;

    homeApps = [{
      inherit tags;
      disableTags = [ "minimal" ];
      packages = [
        "vlc"
        "spotify"
        "tidal-hifi"
      ];
    }];

    apps = {
      spotify = {
        nixpkgs.packages.unfree = [ "spotify" ];
      };
    };
  };
}

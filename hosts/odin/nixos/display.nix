{ host, pkgs, ... }:
let
  useNvidia = host.tags.nvidia or false;
in
{
  services.xserver = {
    videoDrivers = if useNvidia then [ "nvidia" ] else [ "nouveau" ];
  };
}

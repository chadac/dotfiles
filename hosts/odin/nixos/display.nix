{ pkgs, ... }:
{
  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };
}

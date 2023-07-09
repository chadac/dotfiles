{ mkApp, ... }:
{
  steam = mkApp {
    src = ./.;
    nixos = { ... }: {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };
    };
  };

  # mame = mkApp {
  #   src = ./mame;
  #   home = { pkgs, ... }: let
  #     mame = pkgs.callPackage ./mame { };
  #   in {
  #     home.packages = [ mame ];
  #   };
  # };
}

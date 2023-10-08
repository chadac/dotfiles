{ call, mkApp, ... }:
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

  emu = call ./emu { };
}

{ pkgs, lib, home-manager, host, apps, hostApps }:
let
  globalHomeConfiguration = {
    home.stateVersion = "23.05";
    programs.home-manager.enable = true;
  };
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;

  modules = [
    globalHomeConfiguration
    host.homeConfiguration
  ] ++ (apps.genHomeImports hostApps);
}

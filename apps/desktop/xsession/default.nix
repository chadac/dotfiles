{ pkgs, ... }:
{
  type = "app";
  home = { config, ... }: {
    xsession = {
      enable = true;
    };
    xdg = {
      enable = true;
      mime.enable = true;
    };
    home.activation = {
      linkDesktopApplications = {
        after = [ "writeBoundary" "createXdgUserDirectories" ];
        before = [ ];
        data = ''
          rm -rf ${config.xdg.dataHome}/"applications/home-manager"
          mkdir -p ${config.xdg.dataHome}/"applications/home-manager"
          cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/"applications/home-manager/"
        '';
      };
    };
  };
}

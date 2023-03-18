{ mkApp }:
mkApp {
  src = ./.;
  home = { pkgs, config, ... }: {
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
          if [ -d ${config.home.homeDirectory}/.nix-profile/share/applications ]; then
            cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/"applications/home-manager/"
          fi
        '';
      };
    };
  };
}

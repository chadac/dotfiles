{
  nix-config.apps.xsession = {
    tags = [ "x11" ];
    systems = [ "x86_64-linux" "aarch64-linux" ];
    home = { pkgs, config, ... }: {
      xsession = {
        enable = true;
      };
    };
  };
}
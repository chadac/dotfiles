{ mkApp }:
mkApp {
  src = ./.;
  home = { pkgs, ... }: {
    home.packages = with pkgs; [ podman-compose ];
  };
  nixos = {
    # Disable default container config.
    boot.enableContainers = false;

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };

  };
}

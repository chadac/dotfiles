{ mkApp }:
mkApp {
  src = ./.;
  nixos = {
    # Disable default container config.
    boot.enableContainers = false;

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };
}

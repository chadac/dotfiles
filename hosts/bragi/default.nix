# home server
{
  nix-config.hosts.bragi = {
    kind = "nixos";
    system = "x86_64-linux";

    username = "chadac";
    email = "chad@cacrawford.org";
    homeDirectory = "/home/chadac";

    nixos = {
      services.openssh.enable = true;
    };
  };
}

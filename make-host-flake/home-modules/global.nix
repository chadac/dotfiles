{ host, ... }:
{
  home = {
    stateVersion = "23.05";
    username = host.username;
    homeDirectory = host.homeDirectory or "/home/${host.username}";
  };
  programs.home-manager.enable = true;
}

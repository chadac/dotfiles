{ pkgs, ... }:

let
  secrets = import ./amzn-ubuntu.secrets.nix;
in
{
  username = secrets.username;
  homeDirectory = secrets.homeDirectory;

  zsh = {
    enableCompletion = false;
    initExtra = ''
      ${secrets.paths}
    '';
    shellAliases = {
    };
  };

  git = {
    userEmail = secrets.email;
  };

  home.packages = with pkgs; [
  ];
}

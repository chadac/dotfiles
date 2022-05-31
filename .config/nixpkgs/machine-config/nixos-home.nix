{ pkgs, ... }:

{
  username = "chadac";
  homeDirectory = "/home/chadac";

  zsh = {
    enableCompletion = true;
    initExtra = ''
    '';
    shellAliases = {
    };
  };

  git = {
    userEmail = "chad@cacrawford.org";
  };

  home.packages = with pkgs; [
  ];
}

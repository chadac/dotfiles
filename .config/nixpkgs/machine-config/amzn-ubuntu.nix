{ pkgs, ... }:

{
  username = "chadcr";
  homeDirectory = "/home/ANT.AMAZON.COM/chadcr";

  zsh = {
    enableCompletion = false;
    initExtra = ''
      export PATH=$PATH:$HOME/.toolbox/bin
    '';
    shellAliases = {
    };
  };

  git = {
    userEmail = "chadcr@amazon.com";
  };

  home.packages = with pkgs; [
  ];
}

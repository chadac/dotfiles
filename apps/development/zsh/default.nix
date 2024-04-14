{ inputs, ... }:
{
  nix-config.apps.zsh = {
    tags = [ "development" ];

    home = { pkgs, ... }: {
      programs.bash = {
        enable = true;
      };

      programs.zsh = {
        enable = true;
        autocd = true;
        dotDir = ".config/zsh";
        autosuggestion.enable = true;
        enableCompletion = true;

        syntaxHighlighting.enable = true;

        localVariables = {
          ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=10";
        };

        plugins = [
          { name = "zsh-256color"; src = inputs.zsh-256color; }
        ];

        oh-my-zsh = {
          enable = true;
          theme = "tjkirch";
          plugins = [
            "git"
          ];
        };
      };

      programs.fzf = {
        enable = true;
        enableZshIntegration = true;
      };
    };

    nixos = { host, pkgs, ... }: {
      programs.zsh.enable = true;
      users.users.${host.username}.shell = pkgs.zsh;
      environment.shells = [ pkgs.zsh ];
    };
  };
}

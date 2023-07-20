{ host, mkApp, zsh-256color }:
mkApp {
  src = ./.;
  home = { pkgs, ... }: {
    # have bash redirect to zsh
    programs.bash = {
      enable = true;
    };

    programs.zsh = {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      enableAutosuggestions = true;
      enableCompletion = true;

      syntaxHighlighting.enable = true;

      initExtra =
      ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      '';

      localVariables = {
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=10";
      };

      plugins = [
        { name = "zsh-256color"; src = zsh-256color; }
      ];

      oh-my-zsh = {
        enable = true;
        theme = "tjkirch";
        plugins = [
          "git"
        ];
      };
    };

    programs.git.ignores = [
      # direnv
      ".envrc"
      ".direnv/"
    ];

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    home.packages = with pkgs; [
      direnv
    ];
  };

  nixos = { pkgs, ... }: {
    programs.zsh.enable = true;
    users.users.${host.username}.shell = pkgs.zsh;
    environment.shells = [ pkgs.zsh ];
  };
}

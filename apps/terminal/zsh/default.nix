{ pkgs, mkApp, ... }:
mkApp {
  home = {
    # have bash redirect to zsh
    programs.bash = {
      enable = true;
      bashrcExtra = ''
        exec ${pkgs.zsh}/bin/zsh
      '';
    };

    programs.zsh = {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;

      initExtra =
      ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      '';

      localVariables = {
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=10";
      };

      oh-my-zsh = {
        enable = true;
        theme = "tjkirch";
        plugins = [
          "git"
        ];
      };
    };

    home.packages = with pkgs; [
      direnv
    ];
  };
}

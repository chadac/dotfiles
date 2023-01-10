{ pkgs, ... }:
{
  type = "app";
  home = {
    programs.bash.enable = true;
    programs.zsh = {
      enable = true;
      autocd = true;
      dotDir = ".config/zsh";
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;

      initExtra =
      ''
      eval "$(direnv hook zsh)"
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
  };
}

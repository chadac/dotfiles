{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "chadac";
  home.homeDirectory = "/home/chadac";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  services.lorri.enable = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    enableAutosuggestions = true;
    enableCompletion = true;

    initExtra =
    ''
    eval "$(direnv hook zsh)"
    '';

    shellAliases = {
      # https://www.atlassian.com/git/tutorials/dotfiles
      config = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";
    };

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

  home.packages = with pkgs; [
    # Text editors
    vim
    emacs

    # CLI Utilities
    curl
    git
    direnv
    wget
    binutils
    pciutils

    # Editing tools
    texlive.combined.scheme-full
    fontconfig

    # Build tools
    gcc
    gnumake

    # Desktop
    i3
    arandr
    ranger
    gimp
    evince
    blender

    # Web Browsing
    firefox
    thunderbird

    # Chat
    discord
    slack-dark
    signal-desktop

    # Entertainment
    spotify
  ];
}

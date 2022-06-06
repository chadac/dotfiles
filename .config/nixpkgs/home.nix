{ config, pkgs, lib, ... }:

let
  machine-name = import ./machine.nix;
  gen-machine-config = import (./machine-config + "/${machine-name}.nix");
  machine = gen-machine-config pkgs;
in
{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = machine.username;
  home.homeDirectory = machine.homeDirectory;

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
    enableCompletion = machine.zsh.enableCompletion;
    enableSyntaxHighlighting = true;

    initExtra =
    ''
    eval "$(direnv hook zsh)"
    '' + machine.zsh.initExtra;

    localVariables = {
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=10";
    };

    shellAliases = lib.mkMerge [
      machine.zsh.shellAliases
      {
        # https://www.atlassian.com/git/tutorials/dotfiles
        config = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";
        docker = "podman";
      }
    ];

    oh-my-zsh = {
      enable = true;
      theme = "tjkirch";
      plugins = [
        "git"
      ];
    };

    plugins = [
      {
        name = "zsh-256color";
        src = pkgs.fetchFromGitHub {
          owner = "chrissicool";
          repo = "zsh-256color";
          rev = "9d8fa1015dfa895f2258c2efc668bc7012f06da6";
          sha256 = "14pfg49mzl32ia9i9msw9412301kbdjqrm7gzcryk4wh6j66kps1";
        };
      }
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;

    userName = "Chad Crawford";
    userEmail = machine.git.userEmail;

    ignores = [
      # emacs
      "*~"
      "/.emacs.desktop"
      "/.emacs.desktop.lock"
      "*.elc"
      "auto-save-list"
      "tramp"
      ".\#*"
      # directory config
      ".dir-locals.el"
      # nix shell
      "shell.nix"
      # org-mode
      ".org-id-locations"
      "*_archive"
      # pyenv
      ".python-version"
      # python
      "__pycache__/"
      "*.pyc"
      # direnv
      ".envrc"
      # asdf
      ".tool-versions"
    ];

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  xdg = {
    enable = true;
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

    # Virtualisation
    podman

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
  ] ++ machine.home.packages;
}

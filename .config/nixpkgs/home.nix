{ config, pkgs, lib, ... }:

let
  machine-name = import ./machine.nix;
  gen-machine-config = import (./machine-config + "/${machine-name}.nix");
  machine = gen-machine-config pkgs;
  python-env = pkgs.python310.withPackages(p: with p; [ pip pipx ]);
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

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "emacs -nw";
    PIP_USE_FEATURE = "truststore";
    PIPX_BIN_DIR = "$HOME/.local/pipx/bin";
  };

  home.sessionPath = [
    "$HOME/.local/pipx/bin"
  ];

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
    if [ -f $HOME/.asdf/asdf.sh ]; then
      . $HOME/.asdf/asdf.sh
    fi
    export PIPX_BIN_DIR
    '' + machine.zsh.initExtra;

    localVariables = {
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=10";
      NIX_CONF_DIR = "$HOME/.config/nix";
    };

    shellAliases = lib.mkMerge [
      machine.zsh.shellAliases
      {
        # https://www.atlassian.com/git/tutorials/dotfiles
        config = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";
        # docker = "podman";
        # docker-compose = "podman-compose";
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
      ".direnv/"
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
    act

    # Virtualisation
    # podman
    # podman-compose

    # Editing tools
    # texlive.combined.scheme-full

    # Build tools
    gcc
    gnumake
    python-env

    # Development
    nodePackages.pyright

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
    slack
    signal-desktop

    # Entertainment
    spotify
  ] ++ machine.home.packages;
}

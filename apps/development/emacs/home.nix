{ pkgs, lib, config, ... }:
let
  # Generate a custom emacs package that downloads all packages from the
  # use-package command in my init.el
  myEmacs = pkgs.emacsWithPackagesFromUsePackage {
    package = pkgs.emacs-unstable.override({
      withGTK3 = true;
    });
    config = ./init.el;
  };
in {
  home = {
    file = {
      "${config.home.homeDirectory}/.emacs.d/early-init.el" = { source = ./early-init.el; };
      "${config.home.homeDirectory}/.emacs.d/init.el" = { source = ./init.el; };
      "${config.home.homeDirectory}/.emacs.d/lisp" = { source = ./lisp; recursive = true; };
    };
    packages = with pkgs; [
      ispell
    ];
    sessionVariables = {
      EDITOR = "emacsclient";
      VISUAL = "emacsclient";
    };
  };

  services.emacs.enable = true;

  programs.emacs = {
    enable = true;
    package = myEmacs;
  };

  # emacs gitignore
  programs.git.ignores = [
    "*~"
    "/.emacs.desktop"
    "/.emacs.desktop.lock"
    "*.elc"
    "auto-save-list"
    "tramp"
    ".\\#*"
    "\\#*\\#"
    # org-mode
    ".org-id-locations"
    "*_archive"
    # directory config
    ".dir-locals.el"
  ];
}

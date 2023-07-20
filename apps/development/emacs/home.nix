{ pkgs, lib, ... }:
let
  config = pkgs.writeText "default.el" (builtins.readFile ./init.el);
  # Generate a custom emacs package that downloads all packages from the
  # use-package command in my init.el
  myEmacs = pkgs.emacsWithPackagesFromUsePackage {
    package = pkgs.emacs-unstable;
    config = ./init.el;
    extraEmacsPackages = epkgs: [
      # I add my init.el to the site-lisp so that it pulls in my
      # configurations.
      (pkgs.runCommand "default.el" {} ''
         mkdir -p $out/share/emacs/site-lisp
         cp ${config} $out/share/emacs/site-lisp/default.el
       '')
    ];
  };
in {
  home.sessionVariables = {
    EDITOR = "emacs -nw";
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

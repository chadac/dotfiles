{ pkgs, apps, lib, ... }:
let
  config = pkgs.writeText "default.el" (builtins.readFile ./init.el);
  myEmacs = pkgs.emacsWithPackagesFromUsePackage {
    package = pkgs.emacsUnstable;
    config = ./init.el;
    extraEmacsPackages = epkgs: [
      (pkgs.runCommand "default.el" {} ''
         mkdir -p $out/share/emacs/site-lisp
         cp ${config} $out/share/emacs/site-lisp/default.el
       '')
    ];
  };
  # myEmacs = pkgs.emacs.pkgs.withPackages(epkgs: (with epkgs.melpaStablePackages; [
  #   (pkgs.runCommand "default.el" {} ''
  #      mkdir -p $out/share/emacs/site-lisp
  #      cp ${config} $out/share/emacs/site-lisp/default.el
  #    '')
  #   company
  #   company-jedi
  #   #gnu-apl-mode
  #   projectile
  #   magit
  #   evil
  #   yasnippet
  #   posframe
  #   dap-mode
  #   treemacs
  #   treemacs-evil
  #   treemacs-projectile
  #   treemacs-icons-dired
  #   treemacs-magit
  #   treemacs-icons-dired
  #   python-mode
  #   typescript-mode
  #   #kotlin-mode
  #   yaml-mode
  #   #toml-mode
  #   gradle-mode
  #   groovy-mode
  #   nix-mode
  #   rust-mode
  #   editorconfig
  #   #auctex
  #   flycheck
  #   envrc
  # ]));
in {
  type = "app";
  home = {
    home.sessionVariables = {
      EDITOR = "emacs -nw";
    };
    services.emacs.enable = true;
    programs.emacs = {
      enable = true;
      package = myEmacs;
    };
  };
}

{ pkgs, lib, mkApp }:
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
in
mkApp {
  home = {
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
      ".\#*"
      "\#*\#"
      # org-mode
      ".org-id-locations"
      "*_archive"
      # directory config
      ".dir-locals.el"
    ];
  };
}

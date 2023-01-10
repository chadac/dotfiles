{ pkgs, host, mkHomePkg }:
mkHomePkg pkgs.git {
  programs.git = {
    enable = true;

    userName = "Chad Crawford";
    userEmail = host.email;

    ignores = [
      # emacs
      "*~"
      "/.emacs.desktop"
      "/.emacs.desktop.lock"
      "*.elc"
      "auto-save-list"
      "tramp"
      ".\#*"
      "\#*\#"
      # nix
      "result"
      # nix shell
      "shell.nix"
    ];

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };
}

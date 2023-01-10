{ pkgs, callPackage, mkApp, mkHomePkg, ... }:
{
  python = mkHomePkg pkgs.python311 {
    programs.git.ignores = [
      # python
      "__pycache__/"
      "*.pyc"
      ".dmypy.json"
    ];
  };
  emacs = callPackage ./emacs {};
}

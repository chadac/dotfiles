{ host, mkApp }:
mkApp {
  src = ./.;
  home = { pkgs, config, ... }: {
    programs.git = {
      enable = true;

      userName = "Chad Crawford";
      userEmail = host.email;

      ignores = [
        # nix
        "result"
        "result-man"
        # nix shell
        "shell.nix"
      ];

      extraConfig = {
        init.defaultBranch = "main";
        # Not sure why this isn't automatically set...
        core.excludesfile = "${config.xdg.configHome}/git/ignore";
      };
    };
  };
}

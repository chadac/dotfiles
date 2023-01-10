{ pkgs, host, mkHomePkg }:
{
  type = "app";
  home = { config, ... }: {
    programs.git = {
      enable = true;

      userName = "Chad Crawford";
      userEmail = host.email;

      ignores = [
        # nix
        "result"
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

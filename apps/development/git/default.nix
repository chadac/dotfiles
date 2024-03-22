{
  nix-config.apps.git = {
    tags = [ "development" ];

    home = { pkgs, host, config, ... }: {
      programs.git = {
        enable = true;

        userName = "Chad Crawford";
        userEmail = host.email;

        lfs.enable = true;

        ignores = [
          # nix
          "result"
          "result-man"
          # nix shell
          "shell.nix"
        ];

        extraConfig = {
          init.defaultBranch = "main";
          # Sign all commits by default
          commit.gpgsign = true;
          # Not sure why this isn't automatically set...
          core.excludesfile = "${config.xdg.configHome}/git/ignore";
        };
      };
    };
    nixos = { ... }: {
      programs.gnupg.agent.enable = true;
    };
  };
}

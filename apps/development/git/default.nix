{
  nix-config.apps.git = {
    tags = [ "development" ];

    home = { pkgs, host, config, ... }: {
      programs.git = {
        enable = true;

        lfs.enable = true;

        signing.format = "openpgp";

        ignores = [
          # nix
          "result"
          "result-man"
          # nix shell
          "shell.nix"
        ];

        settings = {
          user.name = "Chad Crawford";
          user.email = host.email;
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

  nix-config.apps.gpg = {
    tags = [ "development" ];

    home = { pkgs, ... }: {
      programs.gpg = {
        enable = true;
        settings = {
          pinentry-mode = "loopback";
        };
      };

      services.gpg-agent = {
        enable = true;
        pinentry.package = pkgs.pinentry-gtk2;
      };
    };
  };
}

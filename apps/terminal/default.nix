{ call, mkApp }:
{
  git = call ./git { };
  zsh = call ./zsh { };
  essential = mkApp {
    src = ./.;
    home = { pkgs, ... }: {
      home.packages = with pkgs; [
        unzip
        hyperfine
        dig
        jq
        lm_sensors
        pciutils
      ];
    };
  };
}

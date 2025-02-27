{
  # window manager for darwin that is the least intolerable
  nix-config.apps.aerospace = {
    tags = [ "display" ];
    systems = [ "aarch64-darwin" ];
    home = {
      home.file = {
        ".aerospace.toml" = {
          source = ./.aerospace.toml;
        };
      };
    };
    darwin = {
      homebrew.casks = [
        "nikitabobko/tap/aerospace"
      ];
    };
  };
}

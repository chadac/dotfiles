{ config, lib, ... }:
let
  theme = config.nix-config.theme;
in {
  nix-config.apps.wayland = {
    systems = [ "x86_64-linux" "aarch64-linux" ];
    home = (import ./home.nix theme);
    nixos = { host, pkgs, ... }:
    let
      hasNvidia = host.tags.nvidia or false;
      swayCommand = if hasNvidia then "sway --unsupported-gpu" else "sway";
    in {
      # Enable Sway Wayland compositor
      programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
      };
      
      # Ensure proper XDG environment for Wayland
      environment.sessionVariables = {
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "sway";
      };
      
      # Create greeter user
      users.users.greeter = {
        isSystemUser = true;
        group = "greeter";
      };
      users.groups.greeter = {};

      # Session management
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd '${swayCommand}'";
            user = "greeter";
          };
          initial_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd '${swayCommand}'";
            user = "greeter";
          };
        };
      };
    };
  };
}
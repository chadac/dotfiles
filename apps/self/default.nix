{ mkApp, lib }:
let
  url = "https://flakehub.com/f/chadac/dotfiles/1.0.*.tar.gz";
in
mkApp {
  src = ./.;
  home = { pkgs, host, config, ... }: let
    updater = pkgs.callPackage ./updater.nix { inherit host; type = "home-manager"; };
  in {
    # systemd.user.services.dotfiles-updater-hm = {
    #   Service = {
    #     ExecStart = "${updater}/bin/updater";
    #   };
    # };
    # systemd.user.timers.dotfiles-updater-nixos = {
    #   wantedBy = [ "timers.target" ];
    #   partOf = [ "dotfiles-updater-hm.service" ];
    #   timerConfig = {
    #     OnCalendar = "weekly";
    #     Persistent = "true";
    #     Unit = "dotfiles-updater-hm.service";
    #   };
    # };
  };
  nixos = { pkgs, host, config, ... }: let
    updater = pkgs.callPackage ./updater.nix { inherit host; type = "nixos"; };
  in {
    systemd.services.dotfiles-updater-nixos = {
      description = "Updates system NixOS configuration weekly.";
      script = "${updater}/bin/updater";
    };
    systemd.timers.dotfiles-updater-nixos = {
      wantedBy = [ "timers.target" ];
      partOf = [ "dotfiles-updater-nixos.service" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = "true";
        Unit = "dotfiles-updater-nixos.service";
      };
    };
  };
}

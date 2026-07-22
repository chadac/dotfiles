{ config, lib, inputs, ... }: let
  odin = config.nix-config.hosts.odin;
in {
  perSystem = { pkgs, ... }: {
    checks = {
      # Unit tests for wayland display configuration. The test file uses
      # lib.runTests directly (returns a list of failures), so run it and
      # turn any failures into a build failure.
      waylandDisplayTests = let
        failures = import ./apps/display/wayland/tests.nix { inherit lib; };
      in
        if failures == [ ]
        then pkgs.runCommand "wayland-display-tests-passed" { } "touch $out"
        else throw "waylandDisplayTests failed:\n${lib.generators.toPretty { } failures}";

      fullSystemTest = pkgs.testers.runNixOSTest {
      name = "full-system-test";

      # The VM test driver builds its own pkgs (nixpkgs.* is read-only per
      # node), so supply pkgs matching the real host: the emacs-overlay
      # (provides emacsWithPackagesFromUsePackage) and allowUnfree for the
      # host's unfree packages (nvidia, hplip, ...).
      node.pkgs = lib.mkForce (import inputs.nixpkgs {
        inherit (pkgs.stdenv.hostPlatform) system;
        overlays = [ inputs.emacs-overlay.overlay ];
        config.allowUnfree = true;
      });

      nodes = {
        odin = { config, ... }: {
          imports = odin._internal.nixosModules ++ [
            { _module.args.host = odin; }
          ];

          # The driver supplies its own read-only nixpkgs.hostPlatform;
          # hardware-configuration.nix also pins it, which now collides. Drop
          # the real hardware config for the test — the driver provides VM
          # hardware (disks, platform) anyway.
          disabledModules = [ ./hosts/odin/nixos/hardware-configuration.nix ];

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
        };
      };

      testScript = ''
        odin.wait_for_unit("default.target")
        odin.succeed("su -- chadac -c 'which firefox'")
        odin.fail("su -- root -c 'which firefox'")

        with open("output.txt", "w") as f:
            f.write("test")
      '';
    };
    };
  };
}

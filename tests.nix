{ config, ... }: let
  odin = config.nix-config.hosts.odin;
in {
  perSystem = { pkgs, ... }: {
    checks = {
      # Unit tests for wayland display configuration
      waylandDisplayTests = pkgs.nixt ./apps/display/wayland/tests.nix;

      fullSystemTest = pkgs.testers.runNixOSTest {
      name = "full-system-test";

      nodes = {
        odin = { config, pkgs, ... }: {
          imports = odin._internal.nixosModules ++ [
            { _module.args.host = odin; }
          ];

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

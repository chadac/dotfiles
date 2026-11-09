# imageless runtime for odin's k3s: Scooter pods whose root the node realizes
# from a digest-addressed release (github.com/dmadisetti/imageless).
#
# Nodes evaluate nothing (cacheOnly, the module default): a release names a
# rootfs store path that is substituted from the scooter cachix, and the
# release manifest itself comes from Scooter's imageless-catalog branch.
imageless:
{ config, pkgs, lib, ... }:
let
  package = imageless.packages.${pkgs.stdenv.hostPlatform.system}.imageless;

  # containerd cannot set env per handler, so each handler gets a wrapper.
  shim = name: delegate: projection: pkgs.writeShellScript "imageless-runc-${name}" ''
    export IMAGELESS_RUNC=${delegate}
    export IMAGELESS_STORE_PROJECTION=${projection}
    export IMAGELESS_TELEMETRY_PATH=${config.services.imageless.telemetryPath}
    exec ${package}/bin/imageless-runc "$@"
  '';

  handler = name: binary: systemdCgroup: ''

    [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.${name}]
      runtime_type = "io.containerd.runc.v2"
      pod_annotations = ["imageless.run/*"]
      container_annotations = ["imageless.run/*"]
    [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.${name}.options]
      BinaryName = "${binary}"
      SystemdCgroup = ${lib.boolToString systemdCgroup}
  '';
in
{
  imports = [ imageless.nixosModules.imageless ];

  options.odin.imageless.containerdHandlers = lib.mkOption {
    type = lib.types.lines;
    readOnly = true;
    description = "The imageless runtime handlers, for k3s.nix's containerd template.";
  };

  config = {
    services.imageless = {
      enable = true;
      inherit package;
      # k3s runs its own containerd; the handlers go in its template instead.
      containerd.enable = false;
      policy.issuers.scooter = {
        source = {
          kind = "https";
          baseUrl = "https://raw.githubusercontent.com/chadac-me/scooter/imageless-catalog";
        };
        allowedReleases = [ "*" ];
        caches.default = {
          substituter = "https://scooter.cachix.org";
          publicKeys = [ "scooter.cachix.org-1:h/VEWZVG6v2IMahGN8HkT1WM6tQItepuAvvj1subfIo=" ];
        };
      };
    };

    odin.imageless.containerdHandlers =
      # Services see only their own closure.
      handler "imageless" (shim "runc" "${pkgs.runc}/bin/runc" "closure") false
      # The sandbox's overlay store needs /nix/store as one mount, so node projection.
      + handler "imageless-crun" (shim "crun" "${pkgs.crun}/bin/crun" "node") false;
  };
}

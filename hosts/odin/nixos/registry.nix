# A local Docker registry at localhost:5000 that the k3s cluster pulls from.
#
# Why: k3s runs its OWN containerd, separate from the docker daemon. Previously we
# side-loaded images with `k3s ctr images import`, which forced imagePullPolicy
# IfNotPresent/Never (there was no registry to pull from) and made "did I re-import
# the new build?" a manual guessing game. With a real registry, we push tagged
# images (e.g. localhost:5000/agent-host:scooter-git-<sha>) and k3s pulls them
# normally — pull policy stops mattering, and the deployed tag tells us exactly
# what's running. (See nix-config-private's scooter-deploy for the push+compare
# tooling that drives redeploys off the tag.)
#
# The registry is HTTP-only on loopback (a local dev registry, not exposed off-box),
# so both dockerd and k3s must be told to treat it as insecure/plain-http.
{ pkgs, lib, ... }:

let
  registryPort = 5000;
  registryHost = "localhost:${toString registryPort}";
in
{
  # The registry itself (distribution/registry). Loopback-only; data under
  # /var/lib/docker-registry. `enableDelete` lets tooling GC old tags.
  services.dockerRegistry = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = registryPort;
    enableDelete = true;
    enableGarbageCollect = true;
  };

  # dockerd must treat the HTTP registry as insecure so `docker push localhost:5000/…`
  # works without TLS. (This is the daemon we build+push from.)
  virtualisation.docker.daemon.settings.insecure-registries = [ registryHost ];

  # Tell k3s's containerd to pull from the plain-HTTP registry. k3s reads this file
  # at startup and wires containerd's registry config from it.
  environment.etc."rancher/k3s/registries.yaml".text = ''
    mirrors:
      "${registryHost}":
        endpoint:
          - "http://${registryHost}"
    configs:
      "${registryHost}":
        tls:
          insecure_skip_verify: true
  '';

  # k3s must restart after the registries.yaml changes to pick them up. (The file is
  # only read at containerd start.) This is handled by a rebuild switch restarting
  # k3s; noted here so it's not a surprise that a registries.yaml edit needs it.
}

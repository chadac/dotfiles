# A persistent single-node k3s cluster for local Kubernetes dev (e.g. running Scooter
# with real per-conversation sandboxes / web services, instead of a throwaway k3d).
#
# k3s is a lightweight, single-binary Kubernetes that runs its own containerd — no
# docker-in-docker. It starts at boot and exposes a kubeconfig at
# /etc/rancher/k3s/k3s.yaml (world-readable via --write-kubeconfig-mode below, so
# `kubectl` needs no sudo). Stop it when unused with `systemctl stop k3s`.
{ pkgs, lib, ... }:
{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      # World-readable kubeconfig so plain `kubectl` (as chadac) works without sudo.
      "--write-kubeconfig-mode=644"
      # We don't need the bundled Traefik ingress for local dev; drop it to stay lean.
      "--disable=traefik"
    ];
  };

  # Point KUBECONFIG at the k3s config for interactive shells. (The file is created by
  # the k3s service at start; harmless if absent — kubectl just reports no cluster.)
  environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

  # Cluster CLIs on PATH.
  environment.systemPackages = with pkgs; [ kubectl kubernetes-helm k9s ];

  # The API server. (Pod/service traffic stays on the local host; only 6443 needs to
  # be reachable for kubectl — and only locally, so this is conservative.)
  networking.firewall.allowedTCPPorts = [ 6443 ];
}

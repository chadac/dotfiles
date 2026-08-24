# odin as a k3s AGENT in the hybrid cluster (control plane: valhalla, in AWS).
#
# Was a standalone single-node SERVER until the hybrid cluster went in. odin now
# owns the compute-heavy workloads (Scooter agent-host + per-conversation
# sandboxes) while valhalla is the control plane and public ingress. See
# server-config/docs/hybrid-cluster-design.md.
#
# ############################################################################
# DUPLICATED CONFIG — KEEP IN SYNC WITH server-config
#
# The canonical versions live in server-config/apps/{tailscale,k3s-common,
# k3s-agent}.nix, applied there via the `tailnet` / `k8s-agent` tags. odin
# cannot import them today: it is built from nix-config-private -> dotfiles,
# a different flake from server-config -> nix-config-modules.
#
# FUTURE: server-config exports `flakeModule`, so nix-config-private could take
# it as an input and import it, making these tags available to odin and letting
# this file collapse to `tags = { tailnet = true; k8s-agent = true; }`. That is
# the intended end state; this duplication is the interim.
#
# Drift check: ~/code/github.com/chadac/scripts/check-k3s-sync.sh
# (untracked scratch dir — it spans three repos, so it belongs to none of them)
# ############################################################################
{ pkgs, lib, config, ... }:
let
  # Control plane, reached over the tailnet. MagicDNS is not relied on here (see
  # the accept-dns note below) — this is resolved by the readiness gate instead.
  serverHost = "valhalla";
  serverPort = 6443;

  # Written at boot by the gate below; k3s reads config.yaml.d natively.
  # A CONFIG FILE, not an env file: systemd does NOT expand variables in
  # ExecStart, so "--node-ip=$VAR" would reach k3s as a literal string.
  nodeIPConfigFile = "/etc/rancher/k3s/config.yaml.d/10-node-ip.yaml";

  waitForTailnetIP = pkgs.writeShellApplication {
    name = "k3s-wait-for-tailnet-ip";
    runtimeInputs = [ pkgs.tailscale pkgs.jq ];
    text = ''
      # Block until tailscaled reports Running AND an IPv4 is assigned. Ordering
      # k3s After=tailscaled is NOT sufficient: the daemon being up does not mean
      # an address exists. Starting early makes k3s bind odin's LAN address, come
      # up Ready with the wrong IP, and silently blackhole cross-site traffic.
      deadline=$(( SECONDS + 180 ))
      while [ "$SECONDS" -lt "$deadline" ]; do
        if state=$(tailscale status --json 2>/dev/null); then
          backend=$(printf '%s' "$state" | jq -r '.BackendState // empty')
          ip=$(printf '%s' "$state" | jq -r '.TailscaleIPs[]? | select(test("\\."))' | head -n1)
          if [ "$backend" = "Running" ] && [ -n "$ip" ]; then
            # Resolve the control plane from the TAILNET PEER LIST rather than
            # DNS. accept-dns is off (see the tailscale block), so MagicDNS does
            # not resolve "valhalla" here — and hardcoding an IP would break the
            # moment tailscaled re-registers and the address changes.
            # ONLINE peers only. A replaced node leaves a stale entry behind
            # that keeps the original DNS name (the new one registers as
            # "<name>-1"), so matching on name alone can resolve to a dead IP.
            # Observed exactly that: an offline "valhalla" held 100.91.79.106
            # while the live node was "valhalla-1" at 100.105.38.105.
            server=$(printf '%s' "$state" | jq -r \
              --arg h "${serverHost}" \
              '.Peer[]? | select(.Online == true)
                        | select((.HostName // "") == $h or (.DNSName // "" | startswith($h + ".")) or (.DNSName // "" | startswith($h + "-")))
                        | .TailscaleIPs[]? | select(test("\\."))' \
              | head -n1)
            if [ -z "$server" ]; then
              echo "k3s: tailnet is up but peer '${serverHost}' is not visible yet" >&2
              sleep 2
              continue
            fi
            install -Dm0644 /dev/null "${nodeIPConfigFile}"
            {
              printf 'node-ip: "%s"\n' "$ip"
              printf 'server: "https://%s:${toString serverPort}"\n' "$server"
            } > "${nodeIPConfigFile}"
            echo "k3s: tailnet IP is $ip; control plane at $server"
            exit 0
          fi
        fi
        sleep 2
      done
      echo "k3s: timed out waiting for a tailnet IPv4 address" >&2
      exit 1
    '';
  };
in
{
  services.k3s = {
    enable = true;
    role = lib.mkForce "agent";

    # serverAddr is NOT set here on purpose. The control plane is addressed by
    # its TAILNET IP, which is unknown at eval time and changes when tailscaled
    # re-registers; and MagicDNS cannot resolve "valhalla" because accept-dns is
    # off (below). The readiness gate resolves the peer at boot and writes
    # `server:` into config.yaml.d, which k3s reads natively.

    # Cluster join secret, provisioned by sops-nix (see
    # nix-config-private/hosts/odin/nixos/secrets.nix). MUST be byte-identical
    # to server-config's k3s/token — valhalla rejects a mismatched join.
    tokenFile = config.sops.secrets."k3s/token".path;

    extraFlags = toString [
      "--flannel-iface=tailscale0"
      # Site label consumed by the workload split (compute here, ingress on
      # valhalla). See the split table in the design doc.
      "--node-label=node.chadac.dev/site=home"
    ];

    # crun RuntimeClass — REQUIRED, not optional, and carried over verbatim from
    # the previous server config.
    #
    # Scooter's per-conversation sandbox runs systemd as PID 1. Under the default
    # runc it only boots `privileged` — which puts it in the HOST cgroup
    # namespace, where its systemd churns /kubepods.slice at boot, starves the
    # kubelet's own cgroup placement ("Device or resource busy"), and
    # destabilizes the node (on this workstation it previously killed the
    # graphical session). crun delegates a writable cgroup subtree inside the
    # pod's OWN namespace, so the sandbox boots NON-privileged.
    #
    # k3s renders containerd's config from a Go template and will not read an
    # edited config.toml; the template must live at
    # /var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.tmpl. BinaryName
    # is an absolute store path — k3s's containerd does not inherit our PATH.
    containerdConfigTemplate = ''
      {{ template "base" . }}

      [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.crun]
        runtime_type = "io.containerd.runc.v2"
      [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.crun.options]
        BinaryName = "${pkgs.crun}/bin/crun"
        SystemdCgroup = true
    '';
  };

  # Gate k3s on a genuinely-ready tunnel (see the script's comment).
  systemd.services.k3s = {
    after = [ "tailscaled.service" "network-online.target" ];
    wants = [ "tailscaled.service" "network-online.target" ];
    serviceConfig = {
      ExecStartPre = [ "${lib.getExe waitForTailnetIP}" ];
      RestartSec = lib.mkDefault "10s";
    };
  };

  systemd.tmpfiles.rules = [ "d /etc/rancher/k3s/config.yaml.d 0755 root root -" ];

  # Tailnet membership. odin dials OUT to valhalla; nothing inbound is needed.
  services.tailscale = {
    enable = true;
    # Provisioned by sops-nix (nix-config-private/hosts/odin/nixos/secrets.nix).
    authKeyFile = config.sops.secrets."tailscale/auth-key".path;
    openFirewall = true;
    useRoutingFeatures = "none";
    extraSetFlags = [
      "--hostname=odin"
      "--accept-routes=false"
      # Do NOT let Tailscale own /etc/resolv.conf. With accept-dns on, tailscaled
      # points resolv.conf solely at MagicDNS; if it has no upstream configured,
      # tailnet names resolve while ALL PUBLIC DNS FAILS, and every image pull
      # dies in CreatePodSandboxError. odin also has its own LAN DNS needs.
      #
      # This means MagicDNS does NOT resolve "valhalla" here — which is why the
      # readiness gate resolves the control plane from the tailnet PEER LIST
      # (`tailscale status --json`) instead of via DNS.
      "--accept-dns=false"
    ];
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # KUBECONFIG is deliberately NOT set.
  #
  # kubectl already defaults to ~/.kube/config, which is a MUTABLE,
  # multi-context file (EKS, GitLab, kind, minikube, … plus the `valhalla`
  # context for this cluster). Forcing the env var at the system level pins
  # every shell to ONE cluster and shadows that file — you lose `kubectl config
  # use-context` and every other context with it.
  #
  # Two earlier values here were both wrong:
  #   /etc/rancher/k3s/k3s.yaml   — a STALE leftover from when odin ran its own
  #                                 k3s server; still says 127.0.0.1:6443, which
  #                                 now refuses connections.
  #   ~/.kube/valhalla.yaml       — correct cluster, but a single-context file
  #                                 that still shadowed everything else.
  #
  # The valhalla context now lives in ~/.kube/config directly. To (re)create it:
  #   ssh root@<valhalla-tailnet-ip> cat /etc/rancher/k3s/k3s.yaml \
  #     | sed "s|127\.0\.0\.1|<valhalla-tailnet-ip>|g" > /tmp/v.yaml
  #   KUBECONFIG=~/.kube/config:/tmp/v.yaml kubectl config view --flatten > ~/.kube/config.new
  #   mv ~/.kube/config.new ~/.kube/config
  # (the shipped file says 127.0.0.1, which is right ON valhalla and wrong here)
  environment.systemPackages = with pkgs; [ kubectl kubernetes-helm k9s crun ];

  # NOTE: fetching the kubeconfig is NOT automated. It needs credentials odin
  # does not necessarily have (an ssh key valhalla accepts), and a half-working
  # unit that silently does nothing is worse than a documented one-liner:
  #
  #   ssh root@<valhalla-tailnet-ip> cat /etc/rancher/k3s/k3s.yaml \
  #     | sed "s|127\.0\.0\.1|<valhalla-tailnet-ip>|g" > ~/.kube/valhalla.yaml
  #
  # (the shipped file says 127.0.0.1, which is right ON valhalla and wrong here)

  # 6443 is NO LONGER served here (the API server moved to valhalla); the old
  # firewall opening is intentionally gone.

  # Passwordless sudo for `k3s` only, so side-loading images into k3s's own
  # containerd doesn't prompt. Scoped to the binary; not a blanket NOPASSWD.
  security.sudo.extraRules = [{
    users = [ "chadac" ];
    commands = [{
      # The stable PATH symlink people actually type — sudo compares the invoked
      # path literally and does not canonicalize symlinks, so a store-path rule
      # would never match `sudo k3s`.
      command = "/run/current-system/sw/bin/k3s";
      options = [ "NOPASSWD" "SETENV" ];
    }];
  }];
}

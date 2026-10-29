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
            # Seen on 2026-08-23: the instance replacement during the VPC
            # rebuild left an offline "valhalla" holding 100.91.79.106 while
            # the live node registered as "valhalla-1". The stale peer was
            # removed and the live node renamed back to "valhalla" on
            # 2026-08-25, but the Online filter and the "-" suffix match below
            # are what kept the agent pointed at the right node throughout --
            # keep both; any future replacement repeats this.
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
    #
    # SystemdCgroup is FALSE deliberately. crun 1.27.1's systemd driver builds a
    # BPF pin path from the systemd scope name and flattens "." to "_" but NOT
    # "/" (cgroup-systemd.c:1389 bpfprog_path_from_scope). Under Kubernetes the
    # scope is nested — kubepods/pod<uuid>/<id>.scope — so the pin lands at
    # /sys/fs/bpf/crun/kubepods/pod<uuid>/<id>_scope, while the only mkdir on
    # that path (cgroup-systemd.c:1441) is a NON-recursive mkdir of
    # /sys/fs/bpf/crun. The per-pod parents never exist, BPF_OBJ_PIN fails
    # ENOENT, and EVERY sandbox create fails. Unfixed upstream as of 1.27.1
    # (introduced in 227bd0f1); their tests only use flat scope names.
    #
    # Device filtering is NOT lost: the cgroupfs driver reaches the same eBPF
    # program through cgroup-resources.c:688, which attaches it via dirfd with a
    # NULL pin path. Only the (systemd-bookkeeping) pin is skipped. This also
    # matches the kubelet, which already runs CgroupDriver=cgroupfs here.
    #
    # WHY THIS BIT ON 2026-09-15 AND NOT THE THREE WEEKS BEFORE: crun caches
    # "systemd rejected this property" markers under <state-root>/.cache/
    # systemd-missing-properties and skips the whole BPF path when BPFProgram is
    # listed (cgroup-systemd.c:1420). That cache lives in /run — tmpfs. A reboot
    # cleared it, crun re-attempted BPFProgram=device, and hit the bug on every
    # container. Same NixOS generation, same kernel; only the tmpfs cache moved.
    containerdConfigTemplate = ''
      {{ template "base" . }}

      [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.crun]
        runtime_type = "io.containerd.runc.v2"
      [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.crun.options]
        BinaryName = "${pkgs.crun}/bin/crun"
        SystemdCgroup = false
    '';
  };

  # Gate k3s on a genuinely-ready tunnel (see the script's comment).
  systemd.services.k3s = {
    # var-lib-rancher.mount is the bind mount declared in
    # hardware-configuration.nix, which puts k3s state on the non-mirrored SATA
    # SSD. REQUIRED, not just ordering: without it k3s starts against an empty
    # /var/lib/rancher, re-registers with fresh certs, and loses every
    # local-path PV backing the Scooter conversations.
    after = [ "tailscaled.service" "network-online.target" "mnt-data.mount" "var-lib-rancher.mount" ];
    wants = [ "tailscaled.service" "network-online.target" ];
    requires = [ "var-lib-rancher.mount" ];
    unitConfig.RequiresMountsFor = [ "/var/lib/rancher" "/mnt/data" ];
    serviceConfig = {
      ExecStartPre = [ "${lib.getExe waitForTailnetIP}" ];
      RestartSec = lib.mkDefault "10s";
    };
  };

  systemd.tmpfiles.rules = [ "d /etc/rancher/k3s/config.yaml.d 0755 root root -" ];

  # ##########################################################################
  # AUTH WATCHDOG
  #
  # Failure mode this exists for: the agent's client credentials stop being
  # accepted by the API server MID-FLIGHT. The kubelet logs a flood of
  #   "Unable to authenticate the request" / x509: certificate signed by
  #   unknown authority
  # and the node goes NotReady, but k3s NEVER EXITS -- so Restart=always never
  # fires, NRestarts stays 0, and the local /healthz keeps returning 200. It is
  # silent: nothing in systemd's view of the unit looks wrong. Observed three
  # times on 2026-08-25 (intervals ~24h, 3h20m, then 15m after a tailnet
  # machine rename). A restart re-fetches the CA and re-issues every cert under
  # /var/lib/rancher/k3s/agent/, which fixes it every time.
  #
  # Detection is deliberately LOCAL AND CREDENTIAL-FREE: it reads this node's
  # own journal for the exact signature. Asking the API server whether we are
  # Ready would need a kubeconfig whose credentials are precisely what has
  # broken -- the check would fail for the same reason as the thing it watches.
  #
  # Root cause is NOT yet established. This is a mitigation, not a fix: it logs
  # loudly at error level so recurrences stay visible in Loki rather than being
  # silently papered over. If this fires regularly, investigate -- do not just
  # let it restart forever.
  # ##########################################################################
  systemd.services.k3s-auth-watchdog = {
    description = "Restart k3s when its API credentials are silently rejected";
    # No wantedBy: this is timer-driven only.
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe (pkgs.writeShellApplication {
        name = "k3s-auth-watchdog";
        runtimeInputs = with pkgs; [ systemd coreutils gnugrep ];
        text = ''
          window="''${WINDOW:-5min}"
          # Empirically ~470 errors accumulate in the first minutes of a real
          # failure; a healthy agent logs none. 20 is far above the noise floor
          # and far below a genuine flood, so a transient blip cannot trip it.
          threshold="''${THRESHOLD:-20}"

          # Scope strictly to the RUNNING pid. Without this, errors from the
          # previous (already-restarted) process stay in the journal window and
          # would retrigger a restart loop against a healthy agent.
          pid=$(systemctl show k3s -p MainPID --value)
          if [ -z "$pid" ] || [ "$pid" = "0" ]; then
            echo "k3s is not running; nothing to watch (systemd will handle it)"
            exit 0
          fi

          # Only count since the current process started, so the window can
          # never reach back past a restart.
          started=$(systemctl show k3s -p ActiveEnterTimestamp --value)
          since="$window ago"
          if [ -n "$started" ]; then
            start_epoch=$(date -d "$started" +%s 2>/dev/null || echo 0)
            window_epoch=$(date -d "$window ago" +%s)
            if [ "$start_epoch" -gt "$window_epoch" ]; then since="$started"; fi
          fi

          count=$(journalctl -u k3s --since "$since" --no-pager 2>/dev/null \
            | grep -F "k3s[$pid]" \
            | grep -c -E "Unable to authenticate the request|Unauthorized" \
            || true)

          if [ "$count" -ge "$threshold" ]; then
            echo "k3s auth failure: $count rejections since $since (pid $pid," \
                 "threshold $threshold) -- restarting k3s" >&2
            systemctl restart k3s
            echo "k3s restarted by auth watchdog" >&2
          fi
        '';
      });
    };
  };

  systemd.timers.k3s-auth-watchdog = {
    description = "Periodic k3s credential-rejection check";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # First check well after boot so a cold start (tailnet gate, CA fetch,
      # cert issuance) is never mistaken for the failure.
      OnBootSec = "10min";
      OnUnitActiveSec = "5min";
      AccuracySec = "30s";
      Unit = "k3s-auth-watchdog.service";
    };
  };

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

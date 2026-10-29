{ host, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./virt.nix
    ./display.nix
    ./docker.nix
    ./k3s.nix
    ./registry.nix
    ./printing.nix

    # KVM Virtual Machine Configurations
    ./vms/workspace.nix
  ];

  time.timeZone = "America/New_York";

  hardware.nvidia.open = host.tags.nvidia or false;

  services.openssh.enable = true;

  boot = {
    supportedFilesystems = [ "nfs" ];
    kernelModules = [ "nfs" ];
    # kernelParams = [ "nouveau.config=NvGspRm=0" ];

    # Disable memory allocation profiling. On 2026-09-15 this host hard-panicked:
    #
    #   BUG: unable to handle page fault for address: ffffffffc04d7010
    #   RIP: __pgalloc_tag_sub+0xc1/0x170        CPU 5, Comm: kswapd0
    #   free_unref_folios -> shrink_folio_list -> evict_folios
    #     -> try_to_shrink_lruvec -> shrink_node -> balance_pgdat -> kswapd
    #   Kernel panic - not syncing: Fatal exception
    #
    # __pgalloc_tag_sub is CONFIG_MEM_ALLOC_PROFILING (on, and enabled by
    # default, in this kernel). The faulting address is in the MODULE range
    # (0xffffffffc...) with RDX 0x20 below it: an allocation tag owned by a
    # module that was unloaded while pages allocated from it were still live.
    # Reclaim later dereferenced the dead tag -> not-present page -> Oops in a
    # context that cannot recover. The kernel is Tainted [O]=OOT_MODULE
    # (nvidia, nvidia_drm, nvidia_uvm, nvidia_modeset).
    #
    # Set as a kernelParam AND a sysctl on purpose: the param takes effect
    # before any module loads or reclaim runs, the sysctl keeps it off if
    # something re-enables it later. Both write the same /proc/sys/vm/
    # mem_profiling. Costs nothing here — we do not use /proc/allocinfo.
    #
    # The trigger was sustained memory pressure from a runaway container loop
    # (see server-config; the crun SystemdCgroup bug + the k3d shadow cluster).
    # Those are fixed, which lowers the odds, but the kernel bug is still there
    # and this is what actually removes the panic path.
    kernelParams = [ "sysctl.vm.mem_profiling=0" ];
    kernel.sysctl."vm.mem_profiling" = 0;
  };
}

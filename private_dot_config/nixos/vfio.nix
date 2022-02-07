# Based on https://www.reddit.com/r/VFIO/comments/p4kmxr/tips_for_single_gpu_passthrough_on_nixos/
# from /u/some_random_guy

{ config, pkgs, ... }:
{
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
  boot.kernelModules = [ "kvm-intel" "vfio-pci" ];

  users.users.chadac = {
    extraGroups = [ "libvirtd" ];
  };

  # Virtualization options
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.ovmf.enable = true;
  };

  systemd.services.libvirtd = {
    path = let
      env = pkgs.buildEnv {
        name = "qemu-hook-env";
        paths = with pkgs; [
          bash
          libvirt
          kmod
          systemd
          ripgrep
          sd
        ];
      };
      in
        [ env ];
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    gnome3.dconf
    libguestfs
  ];

  environment.etc = {
    "libvirt/hooks/qemu" = {
      text =
      ''
      GUEST_NAME="$1"
      HOOK_NAME="$2"
      STATE_NAME="$3"
      MISC="''${@:4}"

      user="chadac"
      BASEDIR="$(dirname $0)"
      '';
      mode = "0755";
    };
    "libvirt/hooks/kvm.conf" = {
      text =
      ''
      VIRSH_GPU_VIDEO=pci_0000_04_00_0
      VIRSH_GPU_AUDIO=pci_0000_04_00_1
      '';
      mode = "0755";
    };
    "libvirt/hooks/qemu.d/workspace/begin/start.sh" = {
      text =
      ''
      #!/run/current-system/sw/bin/bash

      source "/etc/libvirt/hooks/kvm.conf"

      # Reconfigure monitors
      . "/home/chadac/.screenlayout/vm.sh"

      # Unbind VTconsole
      echo 0 > /sys/class/vtconsole/vtcon0/bind
      echo 0 > /sys/class/vtconsole/vtcon1/bind
      '';
      mode = "0755";
    };
  };
}

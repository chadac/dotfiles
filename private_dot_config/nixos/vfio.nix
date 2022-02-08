# Based on https://www.reddit.com/r/VFIO/comments/p4kmxr/tips_for_single_gpu_passthrough_on_nixos/
# from /u/some_random_guy

{ config, pkgs, ... }:
{
  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
  boot.kernelModules = [ "kvm-intel" "vfio-pci" ];
  # From https://forum.level1techs.com/t/nixos-vfio-pcie-passthrough/130916
  # Keeping it simple
  boot.extraModprobeConfig = "options vfio-pci ids=1002:67df,1002:aaf0";
  boot.postBootCommands =
    ''
    DEVS="0000:04:00.0 0000:04:00.1"

    for DEV in $DEVS; do
      echo "vfio-pci" > /sys/bus/pci/devices/$DEV/driver_override
    done
    modprobe -i vfio-pci
    '';

  users.users.chadac = {
    extraGroups = [ "libvirtd" "input" ];
  };

  # Virtualization options
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu.runAsRoot = true;
    qemu.ovmf.enable = true;
    qemu.verbatimConfig =
      ''
      user = "1000"
      cgroup_device_acl = [
        "/dev/input/by-id/usb-SteelSeries_SteelSeries_Sensei_Ten-if01-event-mouse",
        "/dev/input/by-id/usb-Kinesis_Advantage2_Keyboard_314159265359-if01-event-kbd",
        "/dev/null", "/dev/full", "/dev/zero", "/dev/random", "/dev/urandom",
        "/dev/ptmx", "/dev/kvm", "/dev/kqemu", "dev/rtc", "/dev/hpet",
        "/dev/sev"
      ]
      '';
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

  system.activationScripts.libvirt-hooks.text =
    ''
    ln -Tfs /etc/libvirt/hooks /var/lib/libvirt/hooks
    '';

  environment.systemPackages = with pkgs; [
    virt-manager
    gnome3.dconf
    libguestfs
  ];

  environment.etc = {
    "libvirt/hooks/qemu" = {
      text =
        ''
        #!/run/current-system/sw/bin/bash
        #
        # Author: Sebastiaan Meijer (sebastiaan@passthroughpo.st)
        #
        # Copy this file to /etc/libvirt/hooks, make sure it's called "qemu".
        # After this file is installed, restart libvirt.
        # From now on, you can easily add per-guest qemu hooks.
        # Add your hooks in /etc/libvirt/hooks/qemu.d/vm_name/hook_name/state_name.
        # For a list of available hooks, please refer to https://www.libvirt.org/hooks.html
        #
        GUEST_NAME="$1"
        HOOK_NAME="$2"
        STATE_NAME="$3"
        MISC="''${@:4}"

        BASEDIR="$(dirname $0)"

        HOOKPATH="$BASEDIR/qemu.d/$GUEST_NAME/$HOOK_NAME/$STATE_NAME"

        set -e # If a script exits with an error, we should as well.

        # check if it's a non-empty executable file
        if [ -f "$HOOKPATH" ] && [ -s "$HOOKPATH"] && [ -x "$HOOKPATH" ]; then
            eval \"$HOOKPATH\" "$@"
        elif [ -d "$HOOKPATH" ]; then
            while read file; do
                # check for null string
                if [ ! -z "$file" ]; then
                  eval \"$file\" "$@"
                fi
            done <<< "$(find -L "$HOOKPATH" -maxdepth 1 -type f -executable -print;)"
        fi
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
    "libvirt/hooks/qemu.d/workspace/prepare/begin/start.sh" = {
      text =
        ''
        #!/run/current-system/sw/bin/bash

        source "/etc/libvirt/hooks/kvm.conf"

        # Reconfigure monitors
        . "/home/chadac/.screenlayout/vm.sh"

        # Unbind VTconsole
        echo 0 > /sys/class/vtconsole/vtcon0/bind
        echo 0 > /sys/class/vtconsole/vtcon1/bind

        # Unbind EFI Framebuffer
        echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

        # Detach GPU devices from host
        virsh nodedev-detach $VIRSH_GPU_VIDEO
        virsh nodedev-detach $VIRSH_GPU_AUDIO

        # Load vfio module
        modprobe vfio-pci
        '';
      mode = "0755";
    };
    "libvirt/hooks/qemu.d/workspace/release/end/stop.sh" = {
      text =
        ''
        #!/run/current-system/sw/bin/bash

        source "/etc/libvirt/hooks/kvm.conf"

        virsh nodedev-reattach $VIRSH_GPU_VIDEO
        virsh nodedev-reattach $VIRSH_GPU_AUDIO

        . "/home/chacac/.screenlayout/main.sh"

        echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/bind

        echo 1 > /sys/class/vtconsole/vtcon0/bind
        echo 1 > /sys/class/vtconsole/vtcon1/bind
        '';
      mode = "0755";
    };
  };
}

{ lib, ... }:
let
  inherit (lib) hasAttr;
  waylandLib = import ./lib.nix { inherit lib; };
  inherit (waylandLib) mkKanshiConfig;
in
{
  imports = [
    ./sway
  ];

  # Note: displays option is shared with x11 module

  config = {
    nix-config.apps.wayland = {
      tags = [ "wayland" ];
      nixos = { host, pkgs, ... }: {
        # Core Wayland support

        # XDG Desktop Portal for screen sharing, etc.
        xdg.portal = {
          enable = true;
          wlr.enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        };

        # Enable graphics support for Wayland
        hardware.opengl.enable = true;

        # Set up automatic display configuration via kanshi
        systemd.user.services.kanshi = lib.mkIf (hasAttr "displays" host) {
          description = "kanshi display configuration daemon";
          wantedBy = [ "sway-session.target" ];
          partOf = [ "sway-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.kanshi}/bin/kanshi";
            Restart = "always";
            RestartSec = 5;
          };
        };
      };

      home = { host, pkgs, ...}: {
        # Set up kanshi configuration for display management
        home.file.".config/kanshi/config" = lib.mkIf (hasAttr "displays" host) {
          text = mkKanshiConfig host.displays;
        };

        # Wayland utilities
        home.packages = with pkgs; [
          wlr-randr    # Manual display control (like xrandr for Wayland)
          kanshi       # Automatic display configuration
          wl-clipboard # Wayland clipboard utilities
        ];
      };
    };

    nix-config.apps.wayland-hdr = {
      tags = [ "wayland" ];
      systems = [ "x86_64-linux" "aarch64-linux" ];

      nixos = { pkgs, ... }: {
        # Enable HDR support in the kernel and graphics stack
        boot.kernelParams = [
          # Enable HDR support in the kernel
          "amdgpu.color_mgmt_force_gamut_lut=1"
          "amdgpu.dcn_fractional_scaling_enable=1"
        ];

        # Mesa configuration for HDR
        environment.variables = {
          # Enable HDR color management
          "AMD_VULKAN_ICD" = "RADV";
          "RADV_DEBUG" = "checkir";
          # Enable 10-bit color depth
          "WLR_DRM_FORCE_LIBLIFTOFF" = "1";
        };

        # Graphics drivers with HDR support
        hardware.opengl = {
          enable = true;
          extraPackages = with pkgs; [
            # AMD HDR support
            amdvlk
            # Intel HDR support
            intel-media-driver
            # NVIDIA HDR support
            # (nvidia drivers handle this automatically)
          ];
        };

        # Pipewire for HDR audio passthrough
        services.pipewire = {
          enable = lib.mkDefault true;
          alsa.enable = lib.mkDefault true;
          pulse.enable = lib.mkDefault true;
        };
      };

      home = { pkgs, ... }: {
        # HDR utilities and tools
        home.packages = with pkgs; [
          # HDR color management
          colord        # Color management daemon
          argyllcms     # Color calibration tools

          # HDR testing and utilities
          mesa-demos    # For testing OpenGL HDR
        ];

        # Environment variables for HDR applications
        home.sessionVariables = {
          # Force applications to use HDR when available
          "KWIN_DRM_DEVICES" = "/dev/dri/card0";
          # Enable Wayland HDR protocols
          "WLR_DRM_FORCE_LIBLIFTOFF" = "1";
        };
      };
    };
  };
}

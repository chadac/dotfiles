{ inputs, ... }:
let
  tags = [ "chat" ];
in {
  nix-config.homeApps = [
    {
      inherit tags;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      packages = [ "element-desktop" ];
    }
    {
      # Discord on Linux is provided by the nixcord app below (Vencord-patched).
      # Darwin keeps the plain upstream package.
      inherit tags;
      systems = [ "x86_64-darwin" "aarch64-darwin" ];
      packages = [ "discord" ];
    }
    {
      inherit tags;
      systems = [ "x86_64-linux" "x86_64-darwin" ];
      packages = [ "slack" ];
    }
    {
      inherit tags;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      packages = [ "signal-desktop" ];
    }
  ];

  nix-config.apps = {
    slack = {
      nixpkgs.packages.unfree = [ "slack" ];
    };

    # NB: this app is named `nixcord`, not `discord`. An app whose name matches
    # its package (`discord`) does not get its home module applied to NixOS
    # hosts under this framework; a distinct name works correctly.
    nixcord = {
      inherit tags;
      nixpkgs.packages.unfree = [ "discord" ];

      # Vencord-patched Discord, configured declaratively. NOTE: because config
      # is declarative, Vencord's in-app plugin menu will NOT persist changes —
      # enable plugins here instead.
      home = { ... }: {
        imports = [ inputs.nixcord.homeModules.nixcord ];

        programs.nixcord = {
          enable = true;
          discord.vencord.enable = true;

          # Hide the Nitro/boost upsell UI via CSS. CSS is version-proof (unlike
          # plugin keys, a bad selector just does nothing rather than erroring).
          quickCss = ''
            /* Hide Nitro upsell entry in the user settings / gift buttons */
            [class*="premiumUpsell"],
            [class*="nitroUpsell"],
            [aria-label*="Nitro" i][class*="button"],
            [class*="buyButton"] {
              display: none !important;
            }
          '';

          config = {
            useQuickCss = true;

            plugins = {
              # TODO(chadac): add the exact Vencord plugin keys you confirm from
              # the in-app plugin list, e.g.:
              #   disableQuestButton.enable = true;   # quest popups
              #   noDevtoolsWarning.enable  = true;   # console "HOLD UP" banner
              # Left empty for now so the first build can't fail on an unknown
              # plugin name.
            };
          };
        };
      };

      # Network-level blocking: Discord telemetry + common ad / YouTube-embed ad
      # hosts. This is a coarse net (helps with telemetry and some embedded-video
      # ads); full YouTube ad-blocking still needs uBlock Origin in a browser.
      nixos = {
        # Only whole hostnames work in /etc/hosts (not URL paths, so Discord's
        # own /api/science telemetry endpoint can't be blocked here without
        # breaking discord.com — that one needs a Vencord plugin instead).
        networking.extraHosts = ''
          # --- Discord telemetry (dedicated analytics hosts, safe to null) ---
          0.0.0.0 discord-analytics.com
          0.0.0.0 discordapp.io
          # --- generic ad / tracking (helps with some YouTube-embed ads) ---
          0.0.0.0 doubleclick.net
          0.0.0.0 static.doubleclick.net
          0.0.0.0 googleads.g.doubleclick.net
          0.0.0.0 pagead2.googlesyndication.com
          0.0.0.0 ad.doubleclick.net
        '';
      };
    };
  };
}

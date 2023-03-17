{ ... }:
{
  nixos = { pkgs }: {
    services.displayManager.lightdm.enable = true;
  };
}

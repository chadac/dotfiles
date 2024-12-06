{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ cups ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplipWithPlugin ];
  };
}

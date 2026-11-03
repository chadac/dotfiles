{
  # Flash ESP32 boards over USB and reach them by .local name.
  nix-config.apps.microcontrollers = {
    tags = [ "development" ];
    systems = [ "x86_64-linux" "aarch64-linux" ];
    nixos = { host, ... }: {
      users.users.${host.username}.extraGroups = [ "dialout" ];
      services.avahi = {
        enable = true;
        nssmdns4 = true;
      };
    };
  };
}

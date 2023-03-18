let
  hosts = {
    odin = import ./odin;

    # Ubuntu-based work machines
    forseti = {
      type = "home-manager";
      system = "x86_64-linux";
      username = "chadcr";
      homeDirectory = "/home/ANT.AMAZON.COM/chadcr";
      email = "chadcr@amazon.com";
      getApps = apps: [ apps.main ];
    };
  };

  genHostConfig = hostname: config: config // { inherit hostname; };
in builtins.mapAttrs genHostConfig hosts

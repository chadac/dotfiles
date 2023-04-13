{
  type = "home-manager";
  system = "x86_64-linux";
  username = "chadcr";
  homeDirectory = "/home/ANT.AMAZON.COM/chadcr";
  email = "chadcr@amazon.com";
  homeConfiguration = import ./home.nix;
  getApps = apps: [ apps.main ];
  displays = {
    DisplayPort-0 = {
      primary = true;
      mode = "2560x1440";
      pos = "0x136";
      rotate = "right";
      workspace = 1;
    };
    HDMI-A-0 = {
      mode = "2560x1440";
      pos = "1440x1440";
      rotate = "normal";
      workspace = 2;
    };
    DVI-D-0 = {
      mode = "2560x1440";
      pos = "1440x0";
      rotate = "normal";
      workspace = 3;
    };
    DVI-D-1.status = "off";
  };
}

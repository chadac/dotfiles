{
  amzn-laptop = {
    system = "x86_64-linux";
    email = "chadcr@amazon.com";
    homeConfiguration = {
      home.username = "635195093";
      home.homeDirectory = "/home/ANT.AMAZON.COM/chadcr";
    };
    getApps = apps: with apps; [ all ];
  };
}

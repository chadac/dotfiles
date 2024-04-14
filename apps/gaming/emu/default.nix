{
  nix-config.apps.emu = {
    tags = [ "gaming" ];

    # temporary fix while waiting on
    # https://github.com/NixOS/nixpkgs/pull/303494
    nixpkgs.params.overlays = [(final: prev: {
      libretro = prev.libretro // {
        mame = prev.libretro.mame.overrideAttrs(old: {
          src = prev.fetchFromGitHub {
            owner = "libretro";
            repo = "mame";
            rev = "3aa1ff0d6c087ac35530572d09bc42a2591ff78f";
            hash = "sha256-78e+3RSOIIblFMD8ivPw0b3SZyDXe8u0pQiRVwr1NFY=";
          };
        });
      };
    })];

    nixpkgs.packages = {
      unfree = [
        "libretro-fbalpha2012"
        "libretro-fbneo"
        "libretro-fmsx"
        "libretro-genesis-plus-gx"
        "libretro-mame2000"
        "libretro-mame2003"
        "libretro-mame2003-plus"
        "libretro-mame2010"
        "libretro-mame2015"
        "libretro-opera"
        "libretro-picodrive"
        "libretro-snes9x"
        "libretro-snes9x2002"
        "libretro-snes9x2005"
        "libretro-snes9x2005-plus"
        "libretro-snes9x2010"
      ];
      insecure = [ "freeimage" ];
    };

    home = import ./home.nix;
  };
}

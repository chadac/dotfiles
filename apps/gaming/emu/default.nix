{
  nix-config.apps.emu = {
    tags = [ "gaming" ];

    nixpkgs.params.overlays = [(final: prev: rec {
      retroarch = prev.wrapRetroArch {
        settings = {
          assets_directory = "${prev.retroarch-assets}/share/retroarch/assets";
          libretro_info_path = "${prev.libretro-core-info}/share/retroarch/cores";
        };
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

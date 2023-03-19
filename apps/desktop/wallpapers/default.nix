# Downloads and then stores my wallpapers in a location in my home
# folder, then runs `feh` to randomly fill my desktop with these
# wallpapers.
{ mkApp }:
mkApp {
  src = ./.;
  home = { config, pkgs, lib, ... }:
    let
      inherit (builtins) fetchurl;
      inherit (lib) foldl;
      wallDir = "${config.home.homeDirectory}/.local/share/wallpapers";
      fetchWallpaper = { filename, sha256 }:
        let
          wallpaper = fetchurl {
            url = "https://s3-us-west-2.amazonaws.com/cacrawford.resources/wallpapers/${filename}";
            inherit sha256;
          };
        in { "${wallDir}/${filename}" = { source = wallpaper; }; };
    in {
      home.packages = [ pkgs.feh ];
      home.file = foldl (files: coords: files // (fetchWallpaper coords)) { } [
        { filename = "roger-dean-1.jpg"; sha256 = "sha256:16f0y2l4hff87rbhn78r1rr00mjqczj757f1y9wilq5i0lcxrczm"; }
        { filename = "roger-dean-2.jpg"; sha256 = "sha256:1wg5znm82x8dr1p07769xp2cfikcvrl1i1zxmwmrr73464z9q4j9"; }
        { filename = "roger-dean-3.jpg"; sha256 = "sha256:09h7l2m7zlvifdc1bs2v33v2f91pcdq3ic80r4xvmk8cc0zpzh9v"; }
        { filename = "roger-dean-4.jpg"; sha256 = "sha256:09dv2qxzslgrg9gk0d8zsmipklxrzlc0sqjnzbdw5p810j7iy81x"; }
        { filename = "roger-dean-5.jpg"; sha256 = "sha256:1hiigvwa4c2lggcwv7dwgjspjcq6qy4jrwrxxndfmj6q5m5k2cac"; }
        { filename = "roger-dean-6.jpg"; sha256 = "sha256:07596471lj2iinrqwlm7pwlzvgbh1j7r4wjfyrfvyni5lfld0zh0"; }
        { filename = "roger-dean-7.jpg"; sha256 = "sha256:0zzg9ws47afcqjpivvjg16v8zxx4r7sbwnxjy9phlgniw95bsxa2"; }
        { filename = "roger-dean-8.jpg"; sha256 = "sha256:06sgw69hldspriy3lyyphnbi7vj35c1wzc983hi8yrvr5vs04cym"; }
        { filename = "roger-dean-9.jpg"; sha256 = "sha256:1qyzzgsn748p49f64in2rk5k5hnas0dxf59hmr12zq6z81r49844"; }
        { filename = "roger-dean-10.jpg"; sha256 = "sha256:187lf40c0zi7rsdx3yzglgbxwym6vyr06yci1wa4d3jy2zm9bx7s"; }
        { filename = "roger-dean-11.jpg"; sha256 = "sha256:1fmr4zwc76m3dwa0hgj9pnfaz4yvzhprxz96qlih2spm7j89aqcv"; }
        { filename = "roger-dean-12.jpg"; sha256 = "sha256:0sp7cx3rrnlqk2w0c5ypbnfrxs54nd8wsglsr678m68z3qlrr7ig"; }
        { filename = "roger-dean-13.jpg"; sha256 = "sha256:119zz7ddlwsmfdwqbzl61bszpxmx3x17n46f673yc7pld4nvhl88"; }
      ];

      # Set up a service to run on login
      systemd.user.services.wallpapers = {
        Unit = {
          Description = "Sets up new wallpapers on user login.";
        };
        Install = {
          WantedBy = [ "multi-user.target" ];
        };
        Service = {
          ExecStart = ''${pkgs.feh}/bin/feh --randomize --bg-fill ${wallDir}'';
        };
      };
    };
}

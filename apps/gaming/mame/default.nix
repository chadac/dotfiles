{ fetchFromGitHub, mame, lua5_4 }:
let
  inherit (builtins) filter;
in
mame.overrideAttrs(oldAttrs: rec {
  version = "0.254";

  buildInputs = (filter (p: p.name != "lua5_3") oldAttrs.buildInputs)
    ++ [ lua5_4 ];

  src = fetchFromGitHub {
    owner = "mamedev";
    repo = "mame";
    rev = "mame${builtins.replaceStrings [ "." ] [ "" ] version}";
    sha256 = "sha256-LYSr/6XvtFe+gdfBg8+/r+rW/+K8rm9jgTsNw+aE0I0=";
  };

  patches = oldAttrs.patches ++ [
    ./sol2-fix-define.patch
  ];
})

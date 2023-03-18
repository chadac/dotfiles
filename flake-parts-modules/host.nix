{}
# { config, lib, flake-parts-lib, ... }:
# let
#   inherit (lib)
#     mkOption
#     types
#   ;
#   inherit (flake-parts-lib)
#     mkSubmoduleOptions
#   ;
# in
# {
#   options = {
#     host = lib.mkOption {
#       type = types.anything;
#     };
#     pkgs = lib.mkOption {
#       type = types.anything;
#     };
#   };
#   config = {
#     pkgs = config.pkgs;
#     host = config.host;
#   };
# }

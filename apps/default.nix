/* App-level configurations for everything that goes in dotfiles.
 *
 * This provides both Home Manager and NixOS application configurations.
 *
 * Hosts specify which applications they want to use.
 */
{ pkgs, lib, buildInputs }:
let
  collectImports = property: item:
    let collect = item:
      if (item ? "type" && item.type == "app")
      then if (builtins.hasAttr property item) then [ item.${property} ] else [ ]
      else builtins.concatMap collect (
        if (builtins.isList item) then item else if (builtins.isAttrs item) then (builtins.attrValues item) else [ ]
      );
    in collect item;
  mkApp = { ... }@inputs: inputs // { type = "app"; };
  mkHomePkg = pkg: homeConfig: mkApp {
    home = {
      home.packages = [ pkg ];
    } // homeConfig;
  };
  callPackage = lib.callPackageWith ( buildInputs // {
    inherit mkApp; inherit mkHomePkg; inherit callPackage;
  });
in rec {
  genHomeImports = items: collectImports "home" items;
  genNixosImports = items: collectImports "nixos" items;

  chat = callPackage ./chat { };
  desktop = callPackage ./desktop { };
  development = callPackage ./development { };
  entertainment = callPackage ./entertainment { };
  terminal = callPackage ./terminal { };

  all = [ chat desktop development entertainment terminal ];
  essential = [ development terminal ];
}

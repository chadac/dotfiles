/* App-level configurations for everything that goes in dotfiles.
 *
 * This combines everything
 */
{ pkgs, callPackage, ... }:
let
  collectImports = property: item:
    let collect = item:
      if (item ? "type" && item.type == "app")
      then if (builtins.hasAttr property item) then [ item.${property} ] else [ ]
      else builtins.concatMap collect (
        if (builtins.isList item) then item else if (builtins.isAttrs item) then (builtins.attrValues item) else [ ]
      );
    in collect item;
in rec {
  genHomeImports = items: collectImports "home" items;
  genNixosImports = items: collectImports "nixos" items;
  genPkgsOverlays = items: collectImports "pkgOverlay" items;

  terminal = callPackage ./terminal { };
  desktop = callPackage ./desktop { };
  development = callPackage ./development { };

  all = [ terminal desktop development ];
  essential = [ terminal development ];
}

/* App-level configurations for everything that goes in dotfiles.
 *
 * This provides both Home Manager and NixOS application configurations.
 *
 * Hosts specify which applications they want to use.
 */
{ host, nixpkgs, ... }@inputs:
let
  inherit (nixpkgs) lib;
  inherit (builtins)
    attrNames
    attrValues
    concatMap
    concatLists
    isAttrs
    isList
    hasAttr
    mapAttrs
    toString
    tryEval
    typeOf
  ;
  inherit (lib)
    imap0
    hasSuffix
    traceSeq
  ;

  isApp = obj: isAttrs obj && obj ? "_type" && obj._type == "app";

  # Adds readable names to each app for debugging.
  importTree = root:
    let
      recurse = prefix: node:
        if (isApp node) then node // { name = prefix; }
        else if(isAttrs node) then (mapAttrs (key: child: recurse "${prefix}.${key}" child) node)
        else throw "Unexpected input '${typeOf node}' at '${prefix}'";
    in
      recurse "apps" root;

  flattenTree = apps:
    let
      _collect = prefix: item:
        # This gets added to some attrsets
        if(hasSuffix ".override" prefix || hasSuffix ".overrideDerivation" prefix) then [ ]
        else if(isApp item) then [ item ]
        else if(isList item) then concatLists
          (imap0 (idx: elem: _collect "${prefix}.${toString idx}" elem) item)
        else if(isAttrs item) then concatLists (attrValues (mapAttrs
          (key: elem: _collect "${prefix}.${key}" elem) item))
        else throw "Unexpected input type '${typeOf item}' at '${prefix}'.";
    in
      _collect "apps" apps;

  tryEvalSrc = src: expr: let
    result = tryEval expr;
    in if (result.success) then result.value
       else throw "Could not run express at ${src}";

  mkApp = { src, home ? {}, nixos ? {}, overlay ? null }: {
    _type = "app";
    _file = src;
    home = {
      _file = src;
      imports = [ home ];
    };
    nixos = {
      _file = src;
      imports = [ nixos ];
    };
  } // (if(isNull overlay) then {} else { inherit overlay; });

  homePackage = src: name: mkApp {
    inherit src;
    home = { pkgs, ... }@args: {
      home.packages = [ pkgs."${name}" ];
    };
  };

  call = lib.callPackageWith (
    { inherit call; inherit lib; inherit mkApp; inherit homePackage; } // inputs
  );


  # Identifier for the hostname for automating deployments and such.
  hostApp = mkApp {
    src = ./.;
    home = { host, config, pkgs, ... }: {
      home.file."${config.home.homeDirectory}/.config/dotfiles/host" = {
        enable = true;
        text = host.hostname;
      };
    };
  };

  appTree =
    let
      tree = importTree {
        chat = call ./chat { };
        core = { hostApp = hostApp; };
        desktop = call ./desktop { };
        development = call ./development { };
        entertainment = call ./entertainment { };
        terminal = call ./terminal { };
        virt = call ./virt { };
      };
    in
      tree // {
        main = with tree; [ chat core desktop development entertainment terminal ];
        essential = with tree; [ core development terminal ];
      };

  listAppNames = apps: map (app: app.name) apps;

  getAppAttr = attr: apps: concatMap (app:
    if(hasAttr attr app) then [ app.${attr} ]
    else [ ]
  ) apps;

  hostApps = flattenTree (host.getApps appTree);
in {
  overlays = getAppAttr "overlay" hostApps;
  homeModules = getAppAttr "home" hostApps;
  nixosModules = getAppAttr "nixos" hostApps;
  inherit listAppNames;
}

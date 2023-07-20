# App-level configurations for everything that goes in dotfiles.
#
# This provides both Home Manager and NixOS application configurations.
#
# While generally composable configurations such as this would be
# solved with Nix's module system, I wanted to give hosts the ability
# to specify which apps they wanted to use in a hierarchical fashion.
#
# For example, a host could specify:
#
#     myhost = {
#       apps = apps: apps.development ++ [ apps.chat.slack ];
#     };
#
# And they would only download development and Slack packages, along
# with related configurations.

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
    typeOf
  ;
  inherit (lib)
    imap0
    hasSuffix
    traceSeq
  ;

  # Returns true if the given object is an app.
  isApp = obj: isAttrs obj && obj ? "_type" && obj._type == "app";

  # Imports a tree of apps, giving them readable names while parsing
  # through the tree.
  #
  # For example, the tree { development: { emacs: <app> } } would
  # return a similar tree where
  #
  #    emacs.name = "development.emacs"
  #
  # This is useful for debugging and providing some commands to describe
  # my host configuration in a compact format.
  #
  # Arguments:
  #   - root: The root of the app tree.
  importTree = root:
    let
      recurse = prefix: node:
        if (isApp node) then node // { name = prefix; }
        else if(isAttrs node) then (mapAttrs (key: child: recurse "${prefix}.${key}" child) node)
        else throw "Unexpected input '${typeOf node}' at '${prefix}'";
    in
      recurse "apps" root;

  # Recursively flattens a list or tree of apps into a single list of apps.
  #
  # Arguments:
  #   apps: A list or tree of apps.
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

  # Constructs an "app", which is the base construct for deployments
  # in my configuration.
  #
  # Arguments:
  #   - src: The source directory containing the code. Debugging construct.
  #   - home: A homeConfiguration module.
  #   - nixos: A nixosConfiguration module.
  #   - overlay: An overlay applied to nixpkgs.
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

  # Simple mkApp wrapper that adds a package to home-manager.
  #
  # Arguments:
  #   - src: The source folder.
  #   - name: The name of the pacakge within `nixpkgs`.
  homePackage = src: name: mkApp {
    inherit src;
    home = { pkgs, ... }@args: {
      home.packages = [ pkgs."${name}" ];
    };
  };

  # `callPackage` for apps. This explicitly excludes `pkgs` due to
  # recursion; in order for me to have overlays alongside my apps, I
  # can't have `pkgs` exposed to each app directly. Instead `pkgs`
  # gets passed through the module system/overlay system separately.
  call = lib.callPackageWith (
    { inherit call; inherit lib; inherit mkApp; inherit homePackage; } // inputs
  );

  # An app required for most deployments. I'll use this file for
  # tracking which host is currently deployed to a given system so
  # that automated upgrades can be run on the proper host.
  hostApp = mkApp {
    src = ./.;
    home = { host, config, pkgs, ... }: {
      home.file."${config.home.homeDirectory}/.config/dotfiles/host" = {
        enable = true;
        text = host.hostname;
      };
    };
  };

  # The actual apps, wrapped in a hierarchical tree format.
  appTree =
    let
      tree = importTree {
        chat = call ./chat { };
        core = { hostApp = hostApp; };
        desktop = call ./desktop { };
        development = call ./development { };
        entertainment = call ./entertainment { };
        gaming = call ./gaming { };
        terminal = call ./terminal { };
        virt = call ./virt { };
      };
    in
      tree // {
        full = with tree; [ chat core desktop development entertainment gaming terminal ];
        main = with tree; [ chat core desktop development entertainment terminal ];
        essential = with tree; [ core development terminal ];
      };

  # Lists unique app names within a given list of apps.
  #
  # Arguments:
  #   - apps: A flat list of apps.
  listAppNames = apps: map (app: app.name) apps;

  # Gets an attribute from each app in a flat list if it exists.
  #
  # Arguments:
  #   - apps: A flat list of apps.
  getAppAttr = attr: apps: concatMap (app:
    if(hasAttr attr app) then [ app.${attr} ]
    else [ ]
  ) apps;

  # For the host passed to this file, the list of apps associated with
  # that host.
  hostApps = flattenTree (host.getApps appTree);
in {
  # Host-specific overlays.
  overlays = getAppAttr "overlay" hostApps;
  # Host-specific home-manager modules.
  homeModules = getAppAttr "home" hostApps;
  # Host-specific NixOS modules.
  nixosModules = getAppAttr "nixos" hostApps;

  inherit listAppNames;
}

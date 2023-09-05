{
  writeShellScriptBin,
  host,
  type,
  url ? "https://flakehub.com/f/chadac/dotfiles/1.0.*.tar.gz",
}:
writeShellScriptBin "updater" (
  if(type == "nixos")
  then "nix run ${url}#nixos-rebuild switch -- --flake ${url}#${host.hostname}"
  else "nix run ${url}#home-manager switch -- --flake ${url}#${host.hostname}"
)

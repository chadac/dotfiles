{ callPackage, ... }:
{
  git = callPackage ./git { };
  zsh = callPackage ./zsh { };
}

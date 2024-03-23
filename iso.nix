# alias for iso image as a package
system:
{ inputs, ... }:
{
  flake.packages.${system}.iso = inputs.self.nixosConfigurations."iso-${system}".config.system.build.isoImage;
}

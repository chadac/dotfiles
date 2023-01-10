{ pkgs, mkHomePkg }:
{
  discord = mkHomePkg pkgs.discord { };
  slack = mkHomePkg pkgs.slack { };
}

{ pkgs, ... }:
{
  nix.settings = {
    access-tokens = "gitlab.com=PAT=glpat-cd6XBXCJNyjCa23cCsmM";
  };
}

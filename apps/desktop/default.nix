{ callPackage }:
{
  i3 = callPackage ./i3 { };
  xsession = callPackage ./xsession { };
  Xresources = callPackage ./Xresources { };
}

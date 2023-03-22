{ homePackage }:
{
  discord = homePackage ./. "discord";
  slack = homePackage ./. "slack";
  signal = homePackage ./. "signal-desktop";
}

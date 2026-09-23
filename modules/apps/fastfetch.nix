# The "fastfetch" aspect: the system-information CLI (neofetch's living
# successor) — quick glance at OS, kernel, DE, hardware and uptime.
# https://github.com/fastfetch-cli/fastfetch
{ ... }:
{
  flake.modules.homeManager.fastfetch =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.fastfetch ];
    };
}

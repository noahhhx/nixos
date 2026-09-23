# The "librewolf" aspect: web browser.
{ ... }:
{
  flake.modules.homeManager.librewolf =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.librewolf ];
    };
}

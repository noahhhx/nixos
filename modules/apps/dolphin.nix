# The "dolphin" aspect: file manager.
{ ... }:
{
  flake.modules.homeManager.dolphin =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.kdePackages.dolphin ];
    };
}

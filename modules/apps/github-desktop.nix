{ ... }:
{
  flake.modules.homeManager.github-desktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.github-desktop ];
    };
}

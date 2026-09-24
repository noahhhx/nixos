{ ... }:
{
  flake.modules.homeManager.bluetui =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.bluetui ];
    };
}

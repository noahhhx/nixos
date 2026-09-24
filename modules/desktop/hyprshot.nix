{ ... }:
{
  flake.modules.homeManager.hyprshot =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.hyprshot ];
    };
}
